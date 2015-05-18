#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub dec {
    goto &HTTP::Headers::Fancy::decode_key
}

is dec('x') => 'X';
is dec('Foo') => 'Foo';
is dec('Foo-Bar') => 'FooBar';
is dec('fOO-bAR') => 'FooBar';
is dec('foo_bar') => 'Foo_bar';
is dec('X-Foo') => 'XFoo';
is dec('a-b-c-d-e-f') => 'ABCDEF';

done_testing;
