Spectral correspondence
-----------------------

Copyright (c) 2006-2008
    Richard (Hao) Zhang and Varun Jain
    Latest modification by Oliver van Kaick


This file describes how to use the MATLAB code for "Robust 3D Shape
Correspondence in the Spectral Domain".

    V. Jain and H. Zhang, "Robust 3D Shape Correspondence in the
    Spectral Domain". Proc. Int. Conf. on Shape Modeling and
    Applications (SMI), pp. 118-129, 2006.

The main function call for the spectral correspondence code is
"specCorr3D". Example:
    [K, Z, V1, V2] = specCorr3D('meshes/alien.smf', 'meshes/human.smf', 5);
The description of the input and output parameters can be seen with
"help specCorr3D" or referring to the file specCorr3D.m


File format for triangle meshes
-------------------------------
The mesh files follow a simplified "smf" format: one line of the form "v
<x> <y> <z>" for each vertex and one line "f <v1> <v2> <v3>" for each
face, containing the vertex indices. In smf, vertex indexing starts at
1. The "smf" file format was initially defined in the qslim
simplification package
(http://graphics.cs.uiuc.edu/~garland/software/qslim.html).
Two examples are provided in the "meshes" directory.


Original contents of the file README.txt
----------------------------------------
The original contents of the README file prepared by Varun follow:

General rules for arguments used in functions:

F, X are used to define mesh where F is <f x 3> face matrix and X is <n
x 3> vertex data.  For multiple meshes, this might be F1,X1 and F2,X2
and so on.

k is used to specify the number of eigenvectors used for embedding

K defines the matching between the vertices of two meshes. If there are
n and m vertices in both meshes, then K is an <n x 2> matrix, where
vertices in the first column are matched to vertices in the second
column. So K(i,1)th vertex in mesh 1 is matched to K(i,2)th vertex in
mesh2. Most of the times, the first column of K will be just the numbers
(1,2,3... n) as they just represent all vertices of mesh 1. Actually in
some functions, it is essential that K(i,1) = i.  This is a result of
bad programming on my part and I apologize for that:(

E or V will represent the spectral embedding of a mesh. This is a <n x
k> matrix representing k dimensional spectral embedding where the k
columns are the k eigenvectors with the largest eigenvalues.

A will (almost) always represent the <n x n> pairwise distance matrix of
a mesh. This distance could be geodesic or Euclidean.
