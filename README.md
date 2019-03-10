# NAME

Sandy - A straightforward and complete next-generation sequencing read simulator

[![Build Status](https://travis-ci.org/galantelab/sandy.svg?branch=master)](https://travis-ci.org/galantelab/sandy)
[![CPAN version](https://badge.fury.io/pl/App-Sandy.svg)](https://badge.fury.io/pl/App-Sandy)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2589575.svg)](https://doi.org/10.5281/zenodo.2589575)

# VERSION

version 0.23

# SYNOPSIS

    $ sandy <command> ...

# DESCRIPTION

**SANDY** is a bioinformatics tool that provides a simple engine to simulate next-generation
sequencing for genomic and transcriptomic data. Simulated data works as experimental control
\- a key step to optimize NGS analysis - in comparison to hypothetical models. SANDY is a
straightforward, easy-to-use, fast and highly customizable tool that generates reads requiring
only a FASTA file as input. SANDY can simulate single/paired-end reads from both whole exome
sequencing and RNA-seq as if produced from the most used second and third-generation sequencing
platforms. SANDY’s reads can be simulated with genetic variations such as SNVs, indels and gene
fusions. For customization purposes, SANDY have built-in (native) databases that can be easily
extended with varying gene/transcript expression profiles, sequencing errors, sequencing
coverages and genomic variations.

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

In some cases, you may need to pass the flag '--force' to **cpanm**:

    % cpanm --force App::Sandy

If you concern about speed, you can avoid testing with the flag '--notest':

    % cpanm --notest App::Sandy

For more details, see [INSTALL](https://github.com/galantelab/sandy/blob/master/INSTALL) file

# ACKNOWLEDGMENTS

- Coordination for the Improvement of Higher Level Personnel - [CAPES](http://www.capes.gov.br/)
- Teaching and Research Institute from Sírio-Libanês Hospital - [Group of Bioinformatics](https://www.bioinfo.mochsl.org.br/)

# AUTHORS

- Thiago L. A. Miller <tmiller@mochsl.org.br>
- J. Leonel Buzzo <lbuzzo@mochsl.org.br>
- Felipe R. C. dos Santos <fsantos@mochsl.org.br>
- Helena B. Conceição <hconceicao@mochsl.org.br>
- Rodrigo Barreiro <rbarreiro@mochsl.org.br>
- Gabriela Guardia <gguardia@mochsl.org.br>
- Fernanda Orpinelli <forpinelli@mochsl.org.br>
- Pedro A. F. Galante <pgalante@mochsl.org.br>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
