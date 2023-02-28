[![Sandy logo](share/imgs/sandy.jpeg)](https://galantelab.github.io/sandy/)
## A straightforward and complete next-generation sequencing read simulator

[![build](https://github.com/galantelab/sandy/actions/workflows/ci.yml/badge.svg?branch=dev)](https://github.com/galantelab/sandy/actions/workflows/ci.yml)
[![cpan version](https://badge.fury.io/pl/App-Sandy.svg)](https://badge.fury.io/pl/App-Sandy)
[![docker tags](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://hub.docker.com/r/galantelab/sandy/tags)

**Sandy** is a bioinformatics tool that provides a simple engine to simulate next-generation
sequencing (NGS) reads for genomic and transcriptomic pipelines. Simulated data works as
experimental control \- a key step to optimize NGS analysis - in comparison to hypothetical
models. **Sandy** is a straightforward, easy-to-use, fast and highly customizable tool that
generates reads requiring only a fasta file as input. **Sandy** can simulate **single-end**
and **paired-end** reads from both DNA and RNA sequencing as if produced from the most used
second and third-generation platforms. The tool also tracks a built-in database with predefined
models extracted from real data for sequencer **quality-profiles** (i.e.
[Illumina](https://www.illumina.com/) *hiseq*, *miseq*, *nextseq*), **expression-matrices**
generated from [GTExV8](https://www.gtexportal.org/home/) data for 54 human tissues, and
**genomic-variations** such as SNVs and Indels from [1KGP](https://www.internationalgenome.org/)
and gene fusions from [COSMIC](https://cancer.sanger.ac.uk/cosmic).

For full documentation, please visit <https://galantelab.github.io/sandy/>.

## Features

* Simulate DNA and RNA sequencing

    Simulate `single-end` (long and short fragments) and `paired-end` sequencing reads for **genome**
    and **transcriptome** analysis. The simulation can be customized with raffle seed, sequencing
    coverage, number of reads, fragment mean, output formats (`fastq`, `sam` and their compressed
    versions `fastq.gz` and `bam`), sequence identifier (header of entries in `fastq`) and much more.

* Sequencer **quality-profile**

    **Sandy** generates `fastq` quality entries that mimic the [Illumina](https://www.illumina.com/),
    [PacBio](https://www.pacb.com/) and [Nanopore](https://nanoporetech.com/) sequencers, as well as
    generating the *phred-score* using a statistical model based on the *poisson* distribution.

* RNA-Seq **expression-matrix**

    It is possible to simulate a RNA-Seq which reflects the abundance of gene expression for transcripts
    and genes of a given tissue. For this purpose, **expression-matrices** were created from the gene
    expression data of 54 tissues of the [GTExV8](https://www.gtexportal.org/home/) project.

* Whole-genome sequencing with **genomic-variiation**

    The user can tune the reference genome (eg [GRCh38.p13.genome.fa.gz](https://www.gencodegenes.org/human/)),
    adding homozygous or heterozygous **genomic-variations** such as SNVs, Indels, gene fusions and other
    types of structural variations (eg CNVs, retroCNVs). **Sandy** has in its database **genomic-variations**
    obtained from the [1KGP](https://www.internationalgenome.org/) and from
    [COSMIC](https://cancer.sanger.ac.uk/cosmic).

* User customization

    Users can include their models for **quality-profile**, **expression-matrix** and **genomic-variation**
    in order to adapt the simulation to their needs.

## Installation

There are two recommended ways to obtain **Sandy**: Pulling the official [Docker](https://www.docker.com/)
image and installing through [CPAN](https://metacpan.org/).

### Docker

Assuming that `docker` is already installed on your server, simply run the command:

    $ docker pull galantelab/sandy

For more details, see [docker/README.md](https://github.com/galantelab/sandy/blob/master/docker/README.md)
file.

### CPAN

#### Prerequisites

Along with `perl`, you must have `zlib`, `gcc`, `make` and `cpanm` packages installed:

- Debian/Ubuntu

        % apt-get install perl zlib1g-dev gcc make cpanminus

- CentOS/Fedora

        % yum install perl zlib gcc make perl-App-cpanminus

- Archlinux

        % pacman -S perl zlib gcc make cpanminus

#### Installing with `cpanm`

Install **Sandy** with the following command:

    % cpanm App::Sandy

If you concern about speed, you can avoid testing with the flag `--notest`:

    % cpanm --notest App::Sandy

For more details, see [INSTALL](https://github.com/galantelab/sandy/blob/master/INSTALL) file

## Acknowledgments

| Institution | Site |
| --- | --- |
| Coordination for the Improvement of Higher Level Personnel | [CAPES](http://www.capes.gov.br/) |
| The São Paulo Research Foundation | [FAPESP](https://fapesp.br/en/about) |
| Teaching and Research Institute from Sírio-Libanês Hospital | [Group of Bioinformatics](https://www.bioinfo.mochsl.org.br/) |

## License

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007

