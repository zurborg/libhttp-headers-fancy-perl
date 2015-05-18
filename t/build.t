#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub buildh {
    goto &HTTP::Headers::Fancy::build_field_hash
}

is buildh() => '';
is buildh(xxx=>undef) => 'xxx';
is buildh(xxx=>undef,yyy=>undef) => 'xxx, yyy';
is buildh(xxx=>'',yyy=>undef) => 'xxx=, yyy';
is buildh(xxx=>undef,yyy=>'') => 'xxx, yyy=';
is buildh(xxx=>'=',yyy=>',') => 'xxx="=", yyy=","';

done_testing;
