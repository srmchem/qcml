\d .ml

/ add intercept
addint:{((1;count x 0)#1f),x}

/ regression predict
predict:{[X;theta]theta$addint X}

/ regularized linear regression cost
rlincost:{[l;X;y;theta]
 J:sum (1f%2*n:count y 0)*sum y$/:y-:predict[X;theta];
 if[l>0f;J+:(l%2*n)*x$x:raze @[;0;:;0f]'[theta]];
 J}
lincost:rlincost[0f]

/ regularized linear regression gradient
rlingrad:{[l;X;y;theta]
 g:(1f%n:count y 0)*addint[X]$/:predict[X;theta]-y;
 if[l>0f;g+:(l%n)*@[;0;:;0f]'[theta]];
 g}
lingrad:rlingrad[0f]

/ gradient descent (gf: gradient function)
gd:{[alpha;gf;theta] theta-alpha*gf theta}

/ normal equations
mlsq:{flip inv[y$/:y]$x$/:y}

/ feature normalization
zscore:{(x-avg x)%dev x}

/ sigmoid function
sigmoid:{1f%1f+exp neg x}

/ logistic regression predict
lpredict:(')[sigmoid;predict]

/ logistic regression cost
lcost:{sum (-1f%count y 0)*sum each (y*log x)+(1f-y)*log 1f-x}

/ regularized logistic regression cost
rlogcost:{[l;X;y;theta]
 J:lcost[X lpredict/ theta;y];
 if[l>0f;J+:(l%2*count y 0)*x$x:2 raze/ @[;0;:;0f]''[theta]]; / regularization
 J}
logcost:rlogcost[0f]

/ regularized logistic regression gradient
rloggrad:{[l;X;y;theta]
 n:count y 0;
 a:lpredict\[enlist[X],theta];
 d:last[a]-y;
 a:addint each -1_a;
 d:{[d;theta;a]1_(flip[theta]$d)*a*1f-a}\[d;reverse 1_theta;reverse 1_a],enlist d;
 g:(a($/:)'d)%n;
 if[l>0f;g+:(l%n)*@[;0;:;0f]''[theta]]; / regularization
 g}
loggrad:rloggrad[0f]

rlogcostgrad:{[l;X;y;theta]
 J:sum rlogcost[l;X;y;2 enlist/ theta];
 g:2 raze/ rloggrad[l;X;y;2 enlist/ theta];
 (J;g)}
logcostgrad:rlogcostgrad[0f]

rlogcostgradf:{[l;X;y]
 Jf:(sum rlogcost[l;X;y]enlist enlist@);
 gf:(raze rloggrad[l;X;y]enlist enlist @);
 (Jf;gf)}
logcostgradf:rlogcostgradf[0f]

/ Glorot and Bengio (2010)
rweights:{neg[e]+x cut (x*y)?2*e:sqrt 6%y+x+:1} / random weights

/ (m)inimization (f)unction, (c)ost (g)radient (f)unction
onevsall:{[mf;cgf;y;lbls] (mf cgf "f"$y=) peach lbls}

wmax:first idesc@               / where max?

/ predict each number and pick best
predictonevsall:{[X;theta]wmax each flip X lpredict/ theta}

/ cut a vector into n matrices
mcut:{[n;x](1+-1_n) cut' (sums {x*y+1} prior -1_n) cut x}
diag:{$[0h>t:type x;x;@[n#abs[t]$0;;:;]'[til n:count x;x]]}

/ (f)unction, x, (e)psilon
/ compute partial derivatives if e is a list
numgrad:{[f;x;e](.5%e)*{x[y+z]-x[y-z]}[f;x] peach diag e}

checknngradients:{[l;n]
 theta:2 raze/ .ml.rweights'[-1_n;1_n];
 X:flip rweights[-1+n 0;n 1];
 y:1+(1+til n 1) mod last n;
 ymat:flip diag[last[n]#1f]"i"$y-1;
 g:2 raze/ rloggrad[l;X;ymat] mcut[n] theta; / analytic gradient
 f:(rlogcost[l;X;ymat]mcut[n]@);
 ng:numgrad[f;theta] count[theta]#1e-4; / numerical gradient
 (g;ng)}

/ n can be any network topology dimension
nncost:{[l;n;X;ymat;theta] / combined cost and gradient for efficiency
 theta:mcut[n] theta;
 x:last a:lpredict\[enlist[X],theta];
 n:count ymat 0;
 J:lcost[x;ymat];
 if[l>0f;J+:(l%2*n)*{x$x}2 raze/ @[;0;:;0f]''[theta]]; / regularization
 d:x-ymat;
 a:addint each -1_a;
 d:{[d;theta;a]1_(flip[theta]$d)*a*1f-a}\[d;reverse 1_theta;reverse 1_a],enlist d;
 g:(a($/:)'d)%n;
 if[l>0f;g+:(l%n)*@[;0;:;0f]''[theta]]; / regularization
 (J;2 raze/ g)}

nncostf:{[l;n;X;ymat]
 Jf:(first nncost[l;n;X;ymat]@);
 gf:(last nncost[l;n;X;ymat]@);
 (Jf;gf)}

/ stochastic gradient descent
/ successively call f with theta and randomly sorted n-sized chunks
/ minimization (f)unction, (s)ampling (f)unction bi(n)s
sgd:{[f;sf;n;theta]theta f/ n cut sf count X 0}

/TODO: get more efficient method
covm:{(1%count x 0)*x$/:\:x}
/cvm:{(x+flip(not n=\:n)*x:(n#'0.0),'(x$/:'(n:til count x)_\:x)%count first x)-a*\:a:avg each x}

pca:{[k;X]
 Xn:zscore each X;
 v:last .qml.mev covm Xn;
 Z:(k#v)$Xn; / project onto k dimensions
 Xr:flip[k#v]$Z; /reconstruct initial image
 (v;Z;Xr)}