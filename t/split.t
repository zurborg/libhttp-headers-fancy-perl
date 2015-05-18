#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub splif {
    goto &HTTP::Headers::Fancy::split_field
}

is_deeply { splif() } => {  };
is_deeply { splif(undef) } => {  };
is_deeply { splif('') } => {  };
is_deeply { splif('xxx') } => { xxx => undef };
is_deeply { splif('xxx,yyy') } => { xxx => undef, yyy => undef };
is_deeply { splif('xxx=yyy') } => { xxx => 'yyy' };
is_deeply { splif('xxx=yyy,zzz') } => { xxx => 'yyy', zzz => undef };
is_deeply { splif('xxx=yyy,zzz=aaa') } => { xxx => 'yyy', zzz => 'aaa' };
is_deeply { splif('xxx="yy,yy"') } => { xxx => 'yy,yy' };
is_deeply { splif('xxx="yy=yy"') } => { xxx => 'yy=yy' };
is_deeply { splif('xxx="yy,yy",yyy="zz=zz"') } => { xxx => 'yy,yy', yyy => 'zz=zz' };
is_deeply { splif('xxx="yy=yy",yyy="zz,zz"') } => { xxx => 'yy=yy', yyy => 'zz,zz' };
is_deeply { splif(' a , b , c ') } => { a => undef, b => undef, c => undef };

done_testing;
