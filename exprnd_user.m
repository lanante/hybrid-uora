function x=exprnd_user(lambda,n)
%lambda= average interval per occurence
% k =number of intervals per occurence

% Computes probability
if nargin==1
x=-log(rand)/lambda;
elseif nargin==2
    x=-log(rand(n,1))/lambda;
end
