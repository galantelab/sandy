## Welcome to **SANDY** simulator! ##


If you're looking for a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given FASTA file or expression matrix file,
then **SANDY** is your choice!



### Introduction ###
**SANDY** is a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given FASTA file. Many next-generation
sequencing (NGS) analyses rely on hypothetical models and principles that
are not precisely satisfied in practice. Simulated data, which provides
positive controls would be a perfect way to overcome these difficulties.
Nevertheless, most of NGS simulators are extremely complex to use, they do
not cover all kinds of the desired features needed by the users, and (some)
are very slow to run in a standard computer. Here, we present **SANDY**, a
straightforward, easy to use, fast, complete set of tools to generate
synthetic next-generation sequencing reads. Sandy simulates whole genome
sequencing, whole exome sequencing, RNAseq reads and it presents several
features to the users to manipulate the data. One of the most impressive features
of **SANDY** is the power to simulate polymorphisms as snvs, indels and structural
variations along with the sequencing reads - with no need of further processing
steps. **SANDY** can be used therefore for benchmarking results of a variety of
pipelines in genomics and trancriptomics.

So, among the most killing features, we would like to highlight these:
* Simulate reads for genome or transcriptome from any FASTA-file with a great
number of options to fit your needs.
* Simulate reads from transcriptomic data, based on tissue specific expression
matrix files.
* Simulate reads using 3rd generation sequencing (PacBio and Nanopore)
quality profiles.
* Simulate reads adding many kinds of genomic variations (SNPs, INDELs, Fusions
an others) in a easy to use fashion.
* Choose from a bulk of ready included databases for *quality profiles*,
*expression matrixes* and *genomic variations*.
* Import and record your own datasets to fit real experimental data.
* Run many instances of *SANDY** in a scalable way by pulling its Docker [image](https://hub.docker.com/r/galantelab/sandy).



### Contents at a Glance ###

1. [Introduction](#introduction)
2. [Documentations](#documentations)
3. [Installation](#installation)
4. [Aknowledgements](#aknowledgements)
5. [Authors](#authors)
6. [Citation](#citation)
7. [Copyright and License](#copyright-and-license)



### Documentations ###

1. [Version 0.23 - *latest*](v0.23/main.md)

2. [Version 0.22](v0.22/main.md)

3. [Version 0.19](v0.19/main.md)

4. [Version 0.18](v0.18/main.md)


### Installation ###

#### Prerequisites ####

Along with **Perl**, the user must have **zlib**, **gcc** and **make** packages
installed. To install them according to your distro, use:

* Debian/Ubuntu
```bash
	$ apt-get install perl zlib1g-dev gcc make
```

* CentOS/Fedora
```bash
	$ yum install perl zlib gcc make
```

* Archlinux
```bash
	$ pacman -S perl zlib gcc make
```

**SANDY** uses the *Comprehensive Perl Archive Network*, CPAN, as its package
manager, which allows a good control over all dependencies needed. If you have
Perl installed, then you may have the cpan command utility. At the first run,
cpan will interactively configure your environment and mirror.

If you are not sure, confirm the prerequisites presented and, after this,
install *cpanminus* package manager:
```bash
	$ cpan -i App::cpanminus
```

`App::cpanminus` will provide the `cpanm` utility, which has the capability of
install not only Sandy, but also all its dependencies, recursively.



#### Installing **SANDY** properly ####

Finally install **SANDY** with:
```bash
	$ cpanm App::Sandy
```

**Important:** MacOS users must add an extra option to the command above, like
this:
```bash
	$ cpanm --force App::Sandy
```

#### Or get Sandy in a Docker image ####

If the user prefer to avoid any intallation process and have Docker, you can just
pull *SANDY*'s* [image](https://hub.docker.com/r/galantelab/sandy) from Docker
Hub with:
```bash
	$ docker pull galantelab/sandy
```

And will take the latest version of **SANDY**, ready to rock!
So, to view some instructions about how to use **SANDY** from a docker image, see
the manual or consult the web [tutorial about Sandy usage from docker](https://galantelab.github.io/sandy/v0.22/main.html#docker-usage).

**Important:** Docker has some strict default configurations for memory and CPU
usage on MacOS. Users of this system can change these configurations on their
behalf by accessing the [Preferences menu](https://docs.docker.com/docker-for-mac/#preferences-menu)
on the Docker icon at top right corner of their desktops.

For many more details, see the [INSTALL](https://github.com/galantelab/sandy/blob/master/INSTALL)
file on *SANDY*'s* GitHub [repository](https://github.com/galantelab/sandy).



### Aknowledgements ###

* Coordination for the Improvement of Higher Level Personnel - CAPES
* [Group of Bioinformatics of the Teaching and Research Institute from Sírio-Libanês Hospital](https://www.bioinfo.mochsl.org.br/)



### Authors ###

* Thiago L. A. Miller <tmiller@mochsl.org.br>
* Gabriela Guardia <gguardia@mochsl.org.br>
* J. Leonel Buzzo <lbuzzo@mochsl.org.br>
* Fernanda Orpinelli <forpinelli@mochsl.org.br>
* Felipe R. C. Santos <fsantos@mochsl.org.br>
* Helena B. Conceição <hconceicao@mochsl.org.br>
* Pedro A. F. Galante <pgalante@mochsl.org.br>


### Citation ###

If **SANDY** was somehow useful in your research, please cite it:

**DOI**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1241587.svg)](https://doi.org/10.5281/zenodo.1241587)


**BibTeX entry**
```bash
@misc{thiago_miller_sandy,
	author = {Thiago Miller},
	title  = {galantelab/sandy A straightforward and complete next-generation sequencing read simulator},
	month  = {may},
	year   = {2018},
	doi    = {10.5281/zenodo.1241587},
	url    = {https://doi.org/10.5281/zenodo.1241587}
}
```



### Copyright and License ###

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.
This is free software, licensed under:

`The GNU General Public License, Version 3, June 2007`
