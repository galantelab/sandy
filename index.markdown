---
layout: home
---

**Sandy** is a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given FASTA file. Many next-generation
sequencing (NGS) analyses rely on hypothetical models and principles that
are not precisely satisfied in practice. Simulated data, which provides
positive controls would be a perfect way to overcome these difficulties.
Nevertheless, most of NGS simulators are extremely complex to use, they do
not cover all kinds of the desired features needed by the users, and (some)
are very slow to run in a standard computer. Here, we present **Sandy**, a
straightforward, easy to use, fast, complete set of tools to generate
synthetic next-generation sequencing reads. Sandy simulates whole genome
sequencing, whole exome sequencing, RNAseq reads and it presents several
features to the users to manipulate the data. One of the most impressive features
of **Sandy** is the power to simulate polymorphisms as snvs, indels and structural
variations along with the sequencing reads - with no need of further processing
steps. **Sandy** can be used therefore for benchmarking results of a variety of
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
* Run many instances of **Sandy** in a scalable way by pulling its Docker [image](https://hub.docker.com/r/galantelab/sandy).
