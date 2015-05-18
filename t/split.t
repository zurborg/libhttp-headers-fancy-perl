#!perl

use Test::More;
use HTTP::Headers::Fancy;

sub splif {
    goto &HTTP::Headers::Fancy::split_field
}

is_deeply { splif() } => {  };
is_deeply { splif(undef) } => {  };
is_deeply { splif('') } => {  };
is_deeply { splif('xxx') } => { Xxx => undef };
is_deeply { splif('xxx,yyy') } => { Xxx => undef, Yyy => undef };
is_deeply { splif('xxx=yyy') } => { Xxx => 'yyy' };
is_deeply { splif('xxx=,zzz') } => { Xxx => '', Zzz => undef };
is_deeply { splif('xxx,zzz=') } => { Xxx => undef, Zzz => '' };
is_deeply { splif('xxx=yyy,zzz') } => { Xxx => 'yyy', Zzz => undef };
is_deeply { splif('xxx=yyy,zzz=aaa') } => { Xxx => 'yyy', Zzz => 'aaa' };
is_deeply { splif('xxx="yy,yy"') } => { Xxx => 'yy,yy' };
is_deeply { splif('xxx="yy=yy"') } => { Xxx => 'yy=yy' };
is_deeply { splif('xxx="yy,yy",yyy="zz=zz"') } => { Xxx => 'yy,yy', Yyy => 'zz=zz' };
is_deeply { splif('xxx="yy=yy",yyy="zz,zz"') } => { Xxx => 'yy=yy', Yyy => 'zz,zz' };
is_deeply { splif(' a , b , c ') } => { A => undef, B => undef, C => undef };

done_testing;
