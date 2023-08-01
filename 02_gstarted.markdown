---
layout: page
title: "Getting Started"
permalink: /getting_started/
---

## Contents
{:.no_toc}

1. This will become a table of contents.
{:toc}

We have designed Sandy based on three principles:

- to be easy to install;
- to be easy to use;
- to resemble variabilities found in a real NGS assay.

## Installation

Sandy is easy to install in the three most commonly used operating systems (OS): Linux, Apple’s macOS,
and Microsoft Windows. For more details, see the section [Installation]({{ site.baseurl }}/install).

## Genome simulation

Sandy is easy to use because it requires only an input (`fasta`) file in a streamline command line to
simulate DNA and RNA sequencing for Illumina's, PacBio, and Oxford Nanopore platforms. The user needs
to provide only the reference genomic (for simulating DNA sequencing) or transcriptomic data (for
simulating RNA sequencing) in `fasta` format and run Sandy command-line interface. For example, to
simulate a whole-genome sequencing (human genome) in an Illumina HiSeq platform, users need to type the
following command only:

### Reference genome

If you don't have the reference genome, first follow this step:

{% highlight shell_session %}
$ wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
{% endhighlight %}

or

{% highlight shell_session %}
$ curl https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
{% endhighlight %}

### Sandy example for genome

with quality-profile for Illumina HiSeq 101 read length and coverage of 1x.

{% highlight shell_session %}
$ sandy genome -v -q hiseq_101 -c 1 hg38.fa.gz
{% endhighlight %}

### Sandy example for genome on Docker

{% highlight shell_session %}
$ docker run \
    --rm \
    -u $(id -u):$(id -g) \
    -v $(pwd -P):/mnt \
    -w /mnt \
    galantelab/sandy genome -v -q hiseq_101 -c 1 hg38.fa.gz
{% endhighlight %}

## Transcriptome simulation

It is also straightforward to simulate an RNA sequencing (RNAseq) run using Sandy. The line below is
an example of an RNAseq simulation for the Illumina HiSeq platform with 30 million paired-end reads of
101 bases in length.

### Reference annotation

If you don't have the transcripts fasta file, first follow this step:

{% highlight shell_session %}
$ wget http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_40/gencode.v40.transcripts.fa.gz;
{% endhighlight %}

or

{% highlight shell_session %}
$ curl http://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_40/gencode.v40.transcripts.fa.gz;
{% endhighlight %}

### Sandy example for transcriptome

{% highlight shell_session %}
$ sandy transcriptome -v -q hiseq_101 -f liver -n 30000000 gencode.v40.transcripts.fa.gz
{% endhighlight %}

### Sandy example for transcriptome on Docker

{% highlight shell_session %}
$ docker run \
    --rm \
    -u $(id -u):$(id -g) \
    -v $(pwd -P):/mnt \
    -w /mnt \
    galantelab/sandy transcriptome -v -q hiseq_101 -f liver -n 30000000 gencode.v40.transcripts.fa.gz
{% endhighlight %}
