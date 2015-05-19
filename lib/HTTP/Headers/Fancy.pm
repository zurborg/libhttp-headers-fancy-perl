use strictures 2;

package HTTP::Headers::Fancy;

# ABSTRACT: Fancy naming schema of HTTP headers

# VERSION

=head1 SYNOPSIS

    my %fancy = decode_hash('content-type' => ..., 'x-foo-bar-baf-baz' => ...);
    my $content_type = $fancy{ContentType};
    my $x_foo_bar_baf_baz = $fancy{XFooBarBafBaz};
    
    my %headers = encode_hash(ContentType => ..., x_foo_bar => ...);
    # %headers = ('content-type' => ..., 'x-foo-bar' => ...);

=head1 DESCRIPTION

This module provides method for renaming HTTP header keys to a lightier, easier-to-use format.

=func decode_key

Decode original HTTP header name

    my $new = decode_key($old);

The header field name will be separated by the dash ('-') sign into pieces. Every piece will be lowercased and the first character uppercased. The pieces will be concatenated.

    # Original -> Fancy
    # Accept   Accept
    # accept   Accept
    # aCCEPT   Accept
    # Acc-Ept  AccEpt
    # Content-Type ContentType
    # x-y-z    XYZ
    # xyz      Xyz
    # x-yz     XYz
    # xy-z     XyZ

=cut

sub decode_key {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my $k = shift;
    $k =~ s{^([^-]+)}{ucfirst(lc($1))}e;
    $k =~ s{-+([^-]+)}{ucfirst(lc($1))}ge;
    return ucfirst($k);
}

=func decode_hash

Decode a hash (or HashRef) of HTTP headers and rename the keys

    my %new_hash = decode_hash(%old_hash);
    my $new_hashref = decode_hash($old_hashref);

=cut

sub decode_hash {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my %headers = @_ == 1 ? %{ +shift } : @_;
    foreach my $old ( keys %headers ) {
        my $new = decode_key($old);
        if ( $old ne $new ) {
            $headers{$new} = delete $headers{$old};
        }
    }
    wantarray ? %headers : \%headers;
}

=func encode_key

Encode fancy key name to a valid HTTP header key name

    my $new = encode_key($old);

Any uppercase (if not at beginning) will be prepended with a dash sign. Underscores will be replaced by a dash-sign too. The result will be lowercased.
    
    # Fancy -> Original
    # FooBar   foo-bar
    # foo_bar  foo-bar
    # FoOoOoF  fo-oo-oo-f

=cut

sub encode_key {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my $k = +shift =~ s{_}{-}gr;
    $k =~ s{([^-])([A-Z])}{$1-$2} while $k =~ m{([^-])([A-Z])};
    return lc($k);
}

=func encode_hash

Encode a hash (or HashRef) of HTTP headers and rename the keys

Removes also a keypair if a value in undefined.

    my %new_hash = encode_hash(%old_hash);
    my $new_hashref = encode_hash($old_hashref);

=cut

sub encode_hash {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my %headers = @_ == 1 ? %{ +shift } : @_;
    foreach my $old ( keys %headers ) {
        delete $headers{$old} unless defined $headers{$old};
        my $new = encode_key($old);
        if ( $old ne $new ) {
            $headers{$new} = delete $headers{$old};
        }
    }
    wantarray ? %headers : \%headers;
}

=func split_field_hash

Split a HTTP header field into a hash with decoding of keys

    my %cc = split_field('no-cache, s-maxage=5');
    # %cc = (NoCache => undef, SMaxage => 5);

=cut

sub split_field_hash {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my $value = shift;
    return () unless defined $value;
    pos($value) = 0;
    my %data;
    $value .= ',';
    while (
        $value =~ m{
        \G
        \s*
        (?<key>
            [^=,]+?
        )
        \s*
        (?:
            \s*
            =
            \s*
            (?:
                (?:
                    "
                    (?<value>
                        [^"]*?
                    )
                    "
                )
            |
                (?<value>
                    [^,]*?
                )
            )
        )?
        \s*
        ,+
        \s*
    }gsx
      )
    {
        $data{ decode_key( $+{key} ) } = $+{value};
    }
    return %data;
}

=func split_field_list

Split a field into pieces

    my @list = split_field('"a", "b", "c"');
    # @list = qw( a b c );

Weak values are stored as ScalarRef

    my @list = split_field('"a", W/"b"', W/"c"');
    # @list = ('a', \'b', \'c');

=cut

sub split_field_list {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my $value = shift;
    return () unless defined $value;
    pos($value) = 0;
    my @data;
    $value .= ',';
    while (
        $value =~ m{
        \G
        \s*
        (?<weak>
            W/
        )?
        "
        (?<value>
            [^"]*?
        )
        "
        \s*
        ,+
        \s*
    }gsix
      )
    {

        push @data => $+{weak} ? \$+{value} : $+{value};
    }
    return @data;
}

=func build_field_hash

The opposite method of L</split_field_hash> with encoding of keys.

    my $field_value = build_field(NoCache => undef, MaxAge => 3600);
    # $field_value = 'no-cache,maxage=3600'

=cut

sub build_field_hash {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    my %data = @_;
    return join ', ', sort map {
        encode_key($_)
          . (
            defined( $data{$_} )
            ? '='
              . ( ( $data{$_} =~ m{[=,]} ) ? '"' . $data{$_} . '"' : $data{$_} )
            : '' )
    } keys %data;
}

=func build_field_list

Build a list from pieces

    my $field_value = build_field(qw( a b c ));
    # $field_value = '"a", "b", "c"'

ScalarRefs evaluates to a weak value

    my $field_value = build_fiel('a', \'b', \'c');
    # $field_value = '"a", W/"b", W/"c"';

=cut

sub build_field_list {
    shift if defined $_[0] and $_[0] eq __PACKAGE__;
    return join ', ', map { ref($_) ? 'W/"' . $$_ . '"' : qq{"$_"} } @_;
}

1;
