-module(pollard).
-export([pollard_rho/1, pollard_rho_discrete_log/3]).
-import(random).

%% Greatest common denominator function using Euclidean algorithm
gcd(A, 0) -> A;
gcd(A, B) -> gcd(B, A rem B).

%% Pollard's Rho algorithm for integer factorization
%% Input N is the integer to factor

pollard_rho(N) -> pollard(2,2,0,N).

pollard(X,Y,D,N) when D =:= N -> false;
pollard(X,Y,D,N) when D /= N , D > 0 -> D;
pollard(X,Y,D,N) -> 
 G = random:uniform(N),
 H = random:uniform(random:uniform(G)),
 ND = gcd( abs(G - H), N),
 pollard(G,H,ND,N).

%% Pollard's Rho algorithm for solving discrete logarithm problems.
%% G is a cyclic group of prime order P
%% Input Alpha is is a generator of G
%% Input Beta is an element of G
%% Input N is the group G's modulus

pollard_rho_discrete_log(Alpha, Beta, N) -> p(Alpha, Beta, N, 0, 0, 1, 0, 0, 1, 1).

g(X,N,P) when X rem 3 =:= 2 -> N;
g(X,N,P) when X rem 3 =:= 0 -> 2 * N rem (P - 1);
g(X,N,P) when X rem 3 =:= 1 -> (N + 1) rem (P - 1).

h(X,N,P) when X rem 3 =:= 2 -> (N + 1) rem (P - 1);
h(X,N,P) when X rem 3 =:= 0 -> 2 * N rem (P - 1);
h(X,N,P) when X rem 3 =:= 1 -> N.

f(Alpha, Beta, X,P) when X rem 3 =:= 2 -> (Beta * X) rem P;
f(Alpha, Beta, X,P) when X rem 3 =:= 0 -> (X * X) rem P;
f(Alpha, Beta, X,P) when X rem 3 =:= 1 -> (Alpha * X) rem P.

p(Alpha, Beta, N, A, B, X, A0,B0,X0, I) -> 
  XI = f(Alpha,Beta,X,N),
  AI = g(X,A,N),
  BI = h(X,B,N),
  X2I = f(Alpha,Beta,f(Alpha,Beta,X0,N),N),
  A2I = g( f(Alpha,Beta,X0,N), g( X0, A0, N), N ),
  B2I = h( f(Alpha,Beta,X0,N), h( X0, B0, N), N ),
  io:format("I: ~p | X: ~p AI: ~p BI: ~p X2I: ~p A2I: ~p B2I: ~p ~n",[I, XI, AI, BI, X2I, A2I, B2I]),
  if (XI =:= X2I) -> 
     R = BI - B2I,
     if( R =:= 0) -> false;
       true -> (A2I - AI) rem N end ;
  true -> p(Alpha,Beta, N, AI,BI,XI, A2I, B2I, X2I, I + 1)
  end.

%% Support function for calculating exponents.
%% math:pow relies on floats and I need arbitrarily large integers for exponents
exp(Base,N) when N =:= 1 -> Base;
exp(Base,N) -> Base * exp(Base, N - 1).
