#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub splith {
    goto &HTTP::Headers::Fancy::split_field_hash
}

is_deeply { splith() } => {  };
is_deeply { splith(undef) } => {  };
is_deeply { splith('') } => {  };
is_deeply { splith('xxx') } => { Xxx => undef };
is_deeply { splith('xxx ,yyy') } => { Xxx => undef, Yyy => undef };
is_deeply { splith('xxx=yyy') } => { Xxx => 'yyy' };
is_deeply { splith('xxx= , zzz') } => { Xxx => '', Zzz => undef };
is_deeply { splith('xxx, zzz=') } => { Xxx => undef, Zzz => '' };
is_deeply { splith('xxx=yyy, zzz') } => { Xxx => 'yyy', Zzz => undef };
is_deeply { splith('xxx=yyy, zzz=aaa') } => { Xxx => 'yyy', Zzz => 'aaa' };
is_deeply { splith('xxx="yy,yy"') } => { Xxx => 'yy,yy' };
is_deeply { splith('xxx="yy=yy"') } => { Xxx => 'yy=yy' };
is_deeply { splith('xxx="yy,yy", yyy="zz=zz"') } => { Xxx => 'yy,yy', Yyy => 'zz=zz' };
is_deeply { splith('xxx="yy=yy", yyy="zz,zz"') } => { Xxx => 'yy=yy', Yyy => 'zz,zz' };
is_deeply { splith(' a , b , c ') } => { A => undef, B => undef, C => undef };

done_testing;
