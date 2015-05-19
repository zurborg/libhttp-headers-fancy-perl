#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub buildh {
    goto &HTTP::Headers::Fancy::build_field_hash;
}

sub buildl {
    goto &HTTP::Headers::Fancy::build_field_list;
}

is buildh() => '';
is buildh( xxx => undef ) => 'xxx';
is buildh( xxx => undef, yyy => undef ) => 'xxx, yyy';
is buildh( xxx => '',    yyy => undef ) => 'xxx=, yyy';
is buildh( xxx => undef, yyy => '' )    => 'xxx, yyy=';
is buildh( xxx => '=',   yyy => ',' )   => 'xxx="=", yyy=","';

is buildl(qw( a b c )) => '"a", "b", "c"';

done_testing;
