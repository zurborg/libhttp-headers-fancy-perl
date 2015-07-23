use strictures 2;

package HTTP::Headers::Fancy;

use Exporter qw(import);
use Scalar::Util qw(blessed);

# ABSTRACT: Fancy naming schema of HTTP headers

# VERSION

our @EXPORT_OK = qw(
  decode_key
  encode_key
  decode_hash
  encode_hash
  split_field_hash
  split_field_list
  build_field_hash
  build_field_list
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK, );

=head1 SYNOPSIS

    my %fancy = decode_hash('content-type' => ..., 'x-foo-bar-baf-baz' => ...);
    my $content_type = $fancy{ContentType};
    my $x_foo_bar_baf_baz = $fancy{XFooBarBafBaz};
    
    my %headers = encode_hash(ContentType => ..., x_foo_bar => ...);
    # %headers = ('content-type' => ..., 'x-foo-bar' => ...);

=head1 DESCRIPTION

This module provides method for renaming HTTP header keys to a lightier, easier-to-use format.

=cut

sub _self {
    my @args = @_;
    if ( blessed $args[0] and $args[0]->isa(__PACKAGE__) ) {
        return @args;
    }
    elsif ( defined $args[0] and not ref $args[0] and $args[0] eq __PACKAGE__ )
    {
        return @args;
    }
    else {
        return ( __PACKAGE__, @args );
    }
}

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
    $k =~ s{^([^-]+)}{ucfirst(lc($1))}e;
    $k =~ s{-+([^-]+)}{ucfirst(lc($1))}ge;
    my ( $self, $k ) = _self(@_);
    return ucfirst($k);
}

=func decode_hash

Decode a hash (or HashRef) of HTTP headers and rename the keys

    my %new_hash = decode_hash(%old_hash);
    my $new_hashref = decode_hash($old_hashref);

=cut

sub decode_hash {
    my ( $self, @args ) = _self(@_);
    my %headers = @args == 1 ? %{ $args[0] } : @args;
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
    $k =~ s{([^-])([A-Z])}{$1-$2} while $k =~ m{([^-])([A-Z])};
    my ( $self, $k ) = _self(@_);
    $k =~ s{_}{-}sg;
    return lc($k);
}

=func encode_hash

Encode a hash (or HashRef) of HTTP headers and rename the keys

Removes also a keypair if a value in undefined.

    my %new_hash = encode_hash(%old_hash);
    my $new_hashref = encode_hash($old_hashref);

=cut

sub encode_hash {
    my ( $self, @args ) = _self(@_);
    my %headers = @args == 1 ? %{ $args[0] } : @args;
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
    my ( $self, $value, @rest ) = _self(@_);
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
    my ( $self, $value, @rest ) = _self(@_);
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
    my ( $self, @args ) = _self(@_);
    my %data = @args;
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

    my $field_value = build_field_list(qw( a b c ));
    # $field_value = '"a", "b", "c"'

ScalarRefs evaluates to a weak value

    my $field_value = build_field_list('a', \'b', \'c');
    # $field_value = '"a", W/"b", W/"c"';

=cut

sub build_field_list {
    my ( $self, @args ) = _self(@_);
    return join ', ', map { ref($_) ? 'W/"' . $$_ . '"' : qq{"$_"} } @args;
}

1;
