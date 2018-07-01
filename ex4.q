\l /Users/nick/q/funq/util.q
\l /Users/nick/q/funq/ml.q
\l /Users/nick/q/qml/src/qml.q
\l /Users/nick/q/funq/qmlmm.q
\l /Users/nick/q/funq/fmincg.q

.ml.checknngradients[.1f;3 5 3]

\cd /Users/nick/Downloads/machine-learning-ex4/ex4
X:(400#"F";",")0:`:ex4data1.csv
y:first (1#"F";",")0:`:ex4data2.csv
THETA1:flip (401#"F";",") 0:`:THETA1.csv
THETA2:flip (26#"F";",") 0:`:THETA2.csv

.ml.predict/[X;(THETA1;THETA2)]
YMAT:.ml.diag[10#1f]@\:"i"$y-1
.util.assert[0.28762916516131876] .ml.rlogcost[0f;X;YMAT] (THETA1;THETA2)
.util.assert[0.38376985909092381] .ml.rlogcost[1f;X;YMAT] (THETA1;THETA2)
.util.assert[0.026047433852894011] sum 2 raze/ .ml.rloggrad[0f;X;YMAT] (THETA1;THETA2)
.util.assert[0.0099559365856808548] sum 2 raze/ .ml.rloggrad[1f;X;YMAT] (THETA1;THETA2)

n:400 25 10
YMAT:.ml.diag[last[n]#1f]@\:"i"$y-1
\ts sum each sum each g:.ml.nncut[n] last .ml.nncostgrad[1f;n;X;YMAT;2 raze/ (THETA1;THETA2)]
THETA:2 raze/ .ml.ninit'[-1_n;1_n];

.fmincg.fmincg[50;.ml.nncostgrad[0f;n;X;YMAT];THETA]
.ml.nncostgrad[0f;n;X;YMAT;2 raze/ (THETA1;THETA2)]

THETA:2 raze/ .ml.ninit'[-1_n;1_n];
THETA:2 raze/ (THETA1;THETA2)
THETA:first .fmincg.fmincg[50;.ml.nncostgrad[0f;n;X;YMAT];THETA]

100*avg y=p:1+.ml.predictonevsall[X].ml.nncut[n] THETA
/ visualize hidden features
plt:.util.plot[40;10;.util.c16] .util.hmap 20 cut
plt 1_first THETA1

/ mistakes
\c 100 200
w:-4?where not y=p:1f+.ml.predictonevsall[X].ml.nncut[n] THETA
-1 value (,') over plt each flip X[;w];
show flip([]p;y)w

/ confusion matrix
show .ml.cm[y;p]
