# NAME

Sandy - A straightforward and complete next-generation sequencing read simulator

[![Build Status](https://travis-ci.org/galantelab/sandy.svg?branch=master)](https://travis-ci.org/galantelab/sandy)
[![CPAN version](https://badge.fury.io/pl/App-Sandy.svg)](https://badge.fury.io/pl/App-Sandy)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1421507.svg)](https://doi.org/10.5281/zenodo.1421507)

# VERSION

version 0.21

# SYNOPSIS

    $ sandy <command> ...

# DESCRIPTION

**Sandy** is a bioinformatic tool that provides a simple engine to generate
single-end/paired-end reads from a given fasta file. Many next-generation
sequencing analyses rely on hypothetical models and principles that are
not precisely satisfied in practice. Simulated data, which provides positive
controls, would be a perfect way to overcome these difficulties. Here, we
present Sandy, a straightforward, easy to use, fast, complete set of tools
to generate synthetic second and third-generation sequencing reads. Sandy
simulates whole genome sequencing, whole exome sequencing, RNAseq reads.
Sandy presents also several features to the users manipulate the data, as
well as well-organized database containing the ‘true’ information (based on
the generated data) of the reads position into the genome, gene and transcript
expression, sequencing errors, and the sequencing coverage. One of the most
impressive features of Sandy is the power to simulate polymorphisms as snvs,
indels and structural variations (e.g. gene duplication, retro-duplication,
gene-fusion) along with the sequencing reads - with no need of further processing
steps. Sandy can be used therefore for benchmarking results of a variety of
pipelines in the genomics or transcriptomics, as well as in generating new
hypotheses and helping in the best designing of sequencing projects, possibly
optimizing time and costs.

# INSTALLATION

**Sandy** was designed for Linux based distributions. If you are working with another
type of operating system, such as macOS, Windows, try to use our docker image.
For more details, see [docker/README.md](https://github.com/galantelab/sandy/blob/master/docker/README.md)
file.

## PREREQUISITES

Along with **Perl**, you must have **zlib**, **gcc** and **make** packages installed:

- Debian/Ubuntu

        % apt-get install perl zlib1g-dev gcc make

- CentOS/Fedora

        % yum install perl zlib gcc make

- Archlinux

        % pacman -S perl zlib gcc make

**Sandy** uses the **Comprehensive Perl Archive Network**, [CPAN](https://www.cpan.org/), as its
package manager, which allows a good control over all dependencies needed.
If you have Perl installed, then you may have the **cpan** command utility. At the first run, cpan
will interactively configure your environment and mirror. In doubt, just confirm the default options
presented. After this, install cpanminus:

    % cpan -i App::cpanminus

App::cpanminus will provide the **cpanm** utility, which has the capability of install not only
Sandy, but also all its dependencies recursively.

## INSTALLING

Finally install **Sandy**:

    % cpanm App::Sandy

For more details, see [INSTALL](https://github.com/galantelab/sandy/blob/master/INSTALL) file

# ACKNOWLEDGMENTS

- Coordination for the Improvement of Higher Level Personnel - [CAPES](http://www.capes.gov.br/)
- Teaching and Research Institute from Sírio-Libanês Hospital - [Group of Bioinformatics](https://www.bioinfo.mochsl.org.br/)

# AUTHORS

- Thiago L. A. Miller <tmiller@mochsl.org.br>
- J. Leonel Buzzo <lbuzzo@mochsl.org.br>
- Felipe R. C. dos Santos <fsantos@mochsl.org.br>
- Helena B. Conceição <hconceicao@mochsl.org.br>
- Gabriela Guardia <gguardia@mochsl.org.br>
- Fernanda Orpinelli <forpinelli@mochsl.org.br>
- Pedro A. F. Galante <pgalante@mochsl.org.br>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
