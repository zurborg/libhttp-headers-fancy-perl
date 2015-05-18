#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub build {
    goto &HTTP::Headers::Fancy::build_field
}

is build() => '';
is build(xxx=>undef) => 'xxx';
is build(xxx=>undef,yyy=>undef) => 'xxx,yyy';
is build(xxx=>'',yyy=>undef) => 'xxx=,yyy';
is build(xxx=>undef,yyy=>'') => 'xxx,yyy=';
is build(xxx=>'=',yyy=>',') => 'xxx="=",yyy=","';

done_testing;
