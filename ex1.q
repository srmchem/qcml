\l /Users/nick/q/plot.q
\l /Users/nick/q/qml/src/qml.q

/ least squares cost function
lscost:{[X;y;theta](1f%2*count y)*y$y-:X$theta}
/ gradient descent
gd:{[X;y;alpha;theta] theta+(alpha%count y)*flip[X]$y-X$theta}


data:flip ("FF";",")0:`$":/Users/nick/Downloads/machine-learning-ex1/ex1/ex1data1.txt"
plt data
X:1f,'data[;0]
y:data[;1]
theta:count[first X]#0f
iter:15000
alpha:.01
lscost[X;y;theta]
plt  lscost[X;y] each  iter gd[X;y;alpha]\ theta
gd[X;y;alpha]/[theta]
plt (X[;1];X$gd[X;y;alpha]/[theta])
first flip .qml.mlsq[X;flip enlist y]
enlist[y] lsq flip X

data:flip ("FFF";",")0:`$":/Users/nick/Downloads/machine-learning-ex1/ex1/ex1data2.txt"
plt flip data
X:data[;0 1]
y:data[;2]
/ feature normalize
X:X -\: avg X
X:X %\: dev each flip X
/ add intercept
X:1f,'X
alpha:.01
iter:4000
theta:count[first X]#0f
iter gd[X;y;alpha]/ theta

/ normal equations

solve:{[X;y]inv[fX$X]$(fX:flip X)$y}
first flip .qml.mlsq[X;flip enlist y]
solve[X;y]
enlist[y] lsq flip X

