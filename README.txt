Directories:
-------------
- This directory contains all files needed applying the 3 methods.

- Additional files that were supplied but not used currently, reside in 'other_files' directory. You may want to read the original README as well.

- Meshes examples are located in 'meshes' directory. Use mesh_read_smf function to load them.

- FastImplementations directory contains VS2008 project that implements dijkstra algorithm. The project is VC++ and it depends on Boost library (1.42, but older versions are likely to work as well). 'Release' directory already contains compiled DLL.



Usage examples:
----------------

Original method using spectral embedding:

>> m = mesh_read_smf('meshes/human.smf');
>> mesh_show(m)
>> out_m = transformUsingSE(m);
...
>> mesh_show(out_m)


Improvement of the method using Nystrom:

>> m = mesh_read_smf('meshes/human.smf');
>> mesh_show(m)
>> out_m = transformUsingSENystrom(m, 50);
...
>> mesh_show(out_m)



Danny's method using weights:

>> m = mesh_read_smf('meshes/human.smf');
>> mesh_show(m)
>> out_m = transformUsingWeights(m, 3);
...
>> mesh_show(out_m)
