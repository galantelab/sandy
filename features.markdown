---
layout: page
title: "Features"
permalink: /features/
---

## Contents
{:.no_toc}

1. This will become a table of contents.
{:toc}

## Simulate DNA and RNA sequencing

Simulate **single-end** (long and short fragments) and **paired-end** sequencing reads for
**genome** and **transcriptome** analysis. The simulation can be customized with raffle seed,
sequencing coverage, number of reads, fragment mean, output formats (`fastq`, `sam` and their
compressed versions `fastq.gz` and `bam`), sequence identifier (header of entries in `fastq`)
and much more.

## Sequencer **quality-profile**

**Sandy** generates `fastq` quality entries that mimic the [Illumina](https://www.illumina.com/),
[PacBio](https://www.pacb.com/) and [Nanopore](https://nanoporetech.com/) sequencers, as well as
generating the *phred-score* using a statistical model based on the *poisson* distribution.

## RNA-Seq **expression-matrix**

It is possible to simulate a RNA-Seq which reflects the abundance of gene expression for transcripts
and genes of a given tissue. For this purpose, **expression-matrices** were created from the gene
expression data of 54 tissues of the [GTExV8](https://www.gtexportal.org/home/) project.

## Whole-genome sequencing with **genomic-variiation**

The user can tune the reference genome (eg [GRCh38.p13.genome.fa.gz](https://www.gencodegenes.org/human/)),
adding homozygous or heterozygous **genomic-variations** such as SNVs, Indels, gene fusions and other
types of structural variations (eg CNVs, retroCNVs). **Sandy** has in its database **genomic-variations**
obtained from the [1KGP](https://www.internationalgenome.org/) and from
[COSMIC](https://cancer.sanger.ac.uk/cosmic).

## Custom user models

Users can include their models for **quality-profile**, **expression-matrix** and **genomic-variation**
in order to adapt the simulation to their needs.

## Custom sequence identifier

The sequence identifier, as the name implies, is a string that identifies a biological sequence (usually
nucleotides) within a sequencing data. For example, the `fasta` format includes the sequence identifier
always after the `>` character at the beginning of the line; the `fastq` format always includes it after
the `@` character at the beginning of the line; the `sam` format uses the first column (called the
*query template name*).

| Sequence identifier | File format |
| :-- | :-: |
| \>**MYID and Optional information**<br />ATCGATCG | `fasta` |
| @**MYID and Optional information**<br />ATCGATCG<br />+<br />ABCDEFGH | `fastq` |
| **MYID** 99 chr1 123456 20 8M chr1 123478 30 ATCGATCG ABCDEFGH | `sam` |

Sequence identifiers may be customized in output using a format string passed by the user. This format
is a combination of literal and escaped characters, in a similar fashion to that used in C programming
language’s `printf` function.

For example, simulating a paired-end sequencing you can add the read length, read position and mate
position into all sequence identifiers with the following format:

{% highlight text %}
%i.%U read=%c:%t-%n mate=%c:%T-%N length=%r
{% endhighlight %}

In this case, results in `fastq` format would be:

{% highlight text %}
==> Into R1
@SR.1 read=chr6:979-880 mate=chr6:736-835 length=100
...
==> Into R2
@SR.1 read=chr6:736-835 mate=chr6:979-880 length=100
{% endhighlight %}
