# NAME

Sandy - A straightforward and complete next-generation sequencing read simulator

# VERSION

version 0.18

# SYNOPSIS

    $ sandy <command> ...

# DESCRIPTION

**Sandy** is a bioinformatic tool that provides a simple engine to generate
single-end/paired-end reads from a given fasta file. Many next-generation sequencing
(NGS) analyses rely on hypothetical models and principles that are not precisely
satisfied in practice. Simulated data, which provides positive controls would be a
perfect way to overcome these difficulties. Nevertheless, most of NGS simulators are
extremely complex to use, they do not cover all kinds of the desired features needed
by the users, and (some) are very slow to run in a standard computer. Here, we present
Sandy, a straightforward, easy to use, fast, complete set of tools to generate synthetic
next-generation sequencing reads. Sandy simulates whole genome sequencing, whole exome
sequencing, RNAseq reads and it presents several features to the users manipulate the data.
Sandy can be used therefore for benchmarking results of a variety of pipelines in the
genomics or trancriptomics.

# INSTALLATION

## PREREQUISITES

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

I, Thiago L. A. Miller, would like to thank:

- Pedro A. F. Galante - for his guidance during my doctorate
- Gabriela Guardia, Helena Conceição and Fernanda Orpinelli - for the advices and testing
- J. Leonel Buzzo - for the documentation
- [Group of Bioinformatics of Teaching and Research Institute from Sírio-Libanês Hospital](https://www.bioinfo.mochsl.org.br/)

# AUTHORS

- Thiago L. A. Miller <tmiller@mochsl.org.br>
- Gabriela Guardia <gguardia@mochsl.org.br>
- J. Leonel Buzzo <lbuzzo@mochsl.org.br>
- Fernanda Orpinelli <forpinelli@mochsl.org.br>
- Pedro A. F. Galante <pgalante@mochsl.org.br>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.

This is free software, licensed under:

    The GNU General Public License, Version 3, June 2007
