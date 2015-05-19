#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub enc {
    goto &HTTP::Headers::Fancy::encode_key;
}

is enc('X')       => 'x';
is enc('foo')     => 'foo';
is enc('foO')     => 'fo-o';
is enc('fOo')     => 'f-oo';
is enc('fOO')     => 'f-o-o';
is enc('FFF')     => 'f-f-f';
is enc('xx-xx')   => 'xx-xx';
is enc('AbcXyz')  => 'abc-xyz';
is enc('abc_xyz') => 'abc-xyz';
is enc('abc_Xyz') => 'abc-xyz';

done_testing;
