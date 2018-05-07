## Welcome to Sandy simulator! ##

![logo.png](img/sandy_logo.png)

**Let's make a simulation today???**

If you're looking for a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given FASTA file or expression matrix file,
then *Sandy* is your choice!



### Introduction ###

Many next-generation sequencing (NGS) analyses rely on hypothetical
models and principles that are not precisely satisfied in practice. Simulated
data, which provides positive controls would be a perfect way to overcome
these difficulties. Nevertheless, most of NGS simulators are extremely
complex to use, they do not cover all kinds of the desired features needed by
the users, and (some) are very slow to run in a standard computer. Here, we
present *Sandy*, a straightforward, easy to use, fast, complete set of tools to
generate synthetic next-generation sequencing reads. *Sandy* simulates
whole genome sequencing, whole exome sequencing, RNAseq reads and it
presents several features to the users manipulate the data. Sandy can be
used therefore for benchmarking results of a variety of pipelines in the
genomics or trancriptomics.

Now, project *Sandy* is in it's 0.18 version and has earned enough maturity to
simulate some realistic features, among these:
* Simulate reads from genomic FASTA-files.
* Simulate reads from transcriptomic data, based on expression matrix files.
* Ready included databases for *quality profiles* and *expression matrixes*.
* Import and record your own *expression matrixes* and *quality profiles* to
simulate real experimental data.



### Contents at a Glance ###

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Usage and Option summary](usage.md#usage-and-option-summary)
	1. [General](usage.md#general-syntax)
    2. [Command `genome`, its options and examples](usage.md#the-genome-command)
    3. [Command `transcriptome`, its options and examples](usage.md#the-transcriptome-command)
    4. [Command `custom`, its options and examples](usage.md#the-custom-command)
    5. [Command `quality`, its options and examples](usage.md#the-quality-command)
    6. [Command `expression`, its options and examples](usage.md#the-expression-command)
    7. [Command `help`, its options and examples](usage.md#the-help-command)
4. [Case study examples](case.md#case-study-examples)
5. [Aknowledgements](#aknowledgements)
6. [Author](#author)
7. [Citation](#citation)
8. [Copyright and License](#copyright-and-license)



### Installation ###

You can install it by two different approaches.

1. If you already use `perl` and perl modules `cpanm`, the solution comes
in one line:
	```bash
		$ cpanm App::Sandy
	```
If you only have `perl` but don't have it's modules from the *Comprehensive
Perl Archive Network*, install it easy with the command:
	```bash
		$ cpan -i App::cpanminus
	```
	App::cpanminus will provide the `cpanm` utility, which has the capability of
	install not only Sandy, but also all its dependencies recursively.

2. If you only have `perl`, as a last resort, you can manually install *Sandy*
through the command line by downloading the [tarball](https://github.com/galantelab/sandy/archive/master.tar.gz)
from GitHub, decompressing it and then building it, like this:
	```bash
		$ wget https://github.com/galantelab/sandy/archive/master.tar.gz
		$ tar xzvf master.tar.gz
		$ cd sandy-master
		$ perl Makefile.PL
		$ make && make test
	```
	Then install it properly with:
	```bash
		$ make install
	```

For more details, see the INSTALL file on *Sandy's* GitHub [repository](https://github.com/galantelab/sandy).



### Aknowledgements ###

I, Thiago L. A. Miller, would like to thank:

* Pedro A. F. Galante - for his guidance during my doctorate.
* Gabriela Guardia, Helena Conceição and Fernanda Orpinelli - for the advices
and testing.
* J. Leonel Buzzo - for the documentation.
* [Group of Bioinformatics of the Teaching and Research Institute from Sírio-Libanês Hospital](https://www.bioinfo.mochsl.org.br/)



### Author ###

Thiago L. A. Miller
[<tmiller@mochsl.org.br>](tmiller@mochsl.org.br)



### Citation ###

If *Sandy* was somehow useful in your research, please cite it:

**DOI**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1241600.svg)](https://doi.org/10.5281/zenodo.1241600)


**BibTeX entry**
```bash
	@misc{thiago_miller_2018_1241600,
		author = {Thiago Miller},
		title  = {galantelab/sandy v0.18 A straightforward and complete next-generation sequencing read simulator},
		month  = {may},
		year   = {2018},
		doi    = {10.5281/zenodo.1241600},
		url	   = {https://doi.org/10.5281/zenodo.1241600}
	}
```



### Copyright and License ###

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.
This is free software, licensed under:

`The GNU General Public License, Version 3, June 2007`
