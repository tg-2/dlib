// portable math functions
module dlib.math.portable;

static import std.math;
static import c99=core.stdc.math;
alias floor=std.math.floor;
alias ceil=std.math.ceil;

enum pi(T)=cast(T)3.14159265358979323846264338327950288L;

import std.range,std.algorithm,std.array;
enum table_size=1000;
T cubicIntp(alias f,alias df,alias l,alias r,int size,T)(T x)if(is(T==float)||is(T==double)){
	if(isNaN(x)||isInfinity(x)) return T.init;
	static immutable T[2][] table=iota(0,size+2).map!(i=>T(l)+(T(r)-T(l))*(i%(size+1))/size).map!(x=>[f(x),df(x)*(r-l)/size]).array;
	auto j=size*(x-l)/(r-l);
	auto zero=cast(int)floor(j),one=zero+1;
	auto nx=j-zero;
	auto a=2*(table[zero][0]-table[one][0])+(table[zero][1]+table[one][1]);
	auto b=-3*(table[zero][0]-table[one][0])-(2*table[zero][1]+table[one][1]);
	auto c=table[zero][1], d=table[zero][0];
	auto nxsq=nx*nx;
	return (a*nxsq*nx+b*nxsq)+(c*nx+d);
}

T fmod(T)(T x,T y)if(is(T==float)||is(T==double)){
	auto m=floor(x/y);
	return x-y*m;
}

T sin(T)(T x)if(is(T==float)||is(T==double)){
	if(x<0) return -sin(-x);
	x=fmod(x,2*pi!T);
	if(x>pi!T) return -sin(2*pi!T-x);
	return cubicIntp!(std.math.sin,std.math.cos,0,pi!T,table_size)(x);
}
T asin(T)(T x){
	return atan2(x,sqrt(1-x*x));
}
T cos(T)(T x){
	if(x<0) return cos(-x);
	x=fmod(x,2*pi!T);
	if(x>pi!T) return cos(2*pi!T-x);
	return cubicIntp!(std.math.cos,(x)=>-std.math.sin(x),0,pi!T,table_size)(x);
}

T acos(T)(T x)if(is(T==float)||is(T==double)){
	return atan2(sqrt(1-x*x),x);
}

T tan(T)(T x){ return sin(x)/cos(x); }
T cot(T)(T x){ return cos(x)/sin(x); }

T atan2(T)(T y,T x)if(is(T==float)||is(T==double)){
	return std.math.atan2(y,x); // implementation looks fine
}
T atan(T)(T x)if(is(T==float)||is(T==double)){
	return std.math.atan(x); // implementation looks fine
}
T sqrt(T)(T x)if(is(T==float)||is(T==double)){
	if(__ctfe) return std.math.sqrt(x);
	static if(is(T==float)) return c99.sqrtf(x);
	static if(is(T==double)) return c99.sqrt(x);
}

T cbrt(T)(T x)if(is(T==float)||is(T==double)){
	if(x<0) return -cbrt(-x);
	if(isNaN(x)||isInfinity(x)) return x;
	if(x==0) return 0;
	T a=sqrt(x),b=T.infinity;
	while(a<b){
		b=a;
		a=(2*a+(x/(b*b)))/3;
	}
	return a;
}

T abs(T)(T x){ return x<0?-x:x; }
alias fabs=abs;

alias isNaN=std.math.isNaN;
alias isInfinity=std.math.isInfinity;

version(none):
void main(){
	import std.stdio;
	auto n=100000;
	auto l=-pi!float, r=pi!float;
	auto highest=0f;
	foreach(i;0..n+1){
		auto x=l+(r-l)*i/n;
		highest=max(highest,abs(sin(x)-std.math.sin(x)));
		highest=max(highest,abs(cos(x)-std.math.cos(x)));
	}
	writeln(highest);
}
