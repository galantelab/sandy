---
layout: page
title: "Tutorial"
permalink: /features/
---

## Contents
{:.no_toc}

1. This will become a table of contents.
{:toc}

## Simulate DNA sequencing

To simulate a whole-genome sequencing with **paired-end** reads, you just need a reference
genome file in `FASTA` format for the desired species:

{% highlight shell_session %}
$ sandy genome --sequencing-type paired-end my_genome.fa
{% endhighlight %}

Alternatively, you may customize several parameters for simulation:

{% highlight shell_session %}
$ sandy genome \
    --verbose \    #enable log messages
    --jobs 2 \    #set number of jobs
    --coverage 8 \    #set genome coverage
    --prefix out \    #set prefix output
    --output-format fastq.gz \    #set output format
    --sequencing-type paired-end \    #set sequencing type
    --quality-profile poisson \    #set sequencing quality profile
    --fragment-mean 300 \    #set fragment mean size
    --fragment-stdd 50 \    #set standard deviation of fragment size
    my_genome.fa
{% endhighlight %}

**Output files**

The simulation output file generated for whole-genome sequencing will depend on the `--output-format` (`fastq`, `bam`),
`--join-paired-ends` (mate read pairs into a single file) and `--sequencing-type` (single-end, paired-end) 
options. Along with the simulation output, a file with read counts per chromosome will be produced. In the previous
example, the following output files will be produced:

{% highlight text %}
out_R1_001.fastq.gz
out_R2_001.fastq.gz
out_coverage.tsv
{% endhighlight %}

### Simulate DNA sequencing with custom quality profiles

By default, **Sandy** generates *phred-scores* using a statistical model based on the *Poisson* distribution.
Alternatively, **Sandy** may generate `fastq` quality entries that mimic the [Illumina](https://www.illumina.com/),
[PacBio](https://www.pacb.com/) and [Nanopore](https://nanoporetech.com/) sequencers. You can change it by passing
 `--quality-profile` option:

{% highlight shell_session %}
$ sandy genome --verbose --quality-profile miseq_150 my_transcripts.fa
{% endhighlight %}

Which will output the *phred-scores* according to the *MySeq* sequencer with a read length of 150
bases.

To see all available quality profiles, run:

{% highlight shell_session %}
$ sandy quality
{% endhighlight %}

### Simulate DNA sequencing with genomic variations

The user can also tune the reference genome (e.g. [GRCh38.p13.genome.fa.gz](https://www.gencodegenes.org/human/)),
adding homozygous or heterozygous **genomic variations** such as SNVs, Indels, gene fusions and other
types of structural variations (e.g. CNVs, retroCNVs). **Sandy** provides several bult-in **genomic variations**
obtained from the [1KGP](https://www.internationalgenome.org/) and from
[COSMIC](https://cancer.sanger.ac.uk/cosmic).

So, let's simulate a genome which includes the fusion between the genes *NPM1* and *ALK*:

{% highlight shell_session %}
$ sandy genome --genomic-variation fusion_hg38_NPM1-ALK my_genome.fa
{% endhighlight %}

To see all available genomic variations, run:

{% highlight shell_session %}
$ sandy variation
{% endhighlight %}

## Simulate RNA sequencing

To simulate a RNA sequencing with **paired-end** reads, you just need a reference transcriptome file in `FASTA` format for the desired species:

{% highlight shell_session %}
$ sandy transcriptome --sequencing-type paired-end my_transcripts.fa
{% endhighlight %}

Alternatively, you may customize several parameters for simulation:

{% highlight shell_session %}
$ sandy transcriptome \
    --verbose \    #enable log messages
    --jobs 2 \    #set number of jobs
    --prefix out \    #set prefix output
    --output-format fastq.gz \    #set output format
    --sequencing-type paired-end \    #set paired-end sequencing
    --quality-profile poisson \    #set sequencing quality profile
    --fragment-mean 300 \    #set fragment mean size
    --fragment-stdd 50 \    #set standard deviation of fragment size
    --number-of-reads 1000000 \    #set the number of reads
    --expression-matrix liver \    #set an expression matrix
    my_genome.fa
{% endhighlight %}

**Output files**

The simulation output file generated for RNA sequencing will depend on the `--output-format` (`fastq`, `bam`), 
`--join-paired-ends` (mate read pairs into a single file) and `--sequencing-type` (single-end, paired-end) 
options. Along with the simulation output, a file with the abundances per transcript will be produced, 
and if there is the relationship between genes and their transcripts at the `fasta` header, a file with the
abundances per gene are produced as well. In the previous example, the following output files will be produced:

{% highlight text %}
out_R1_001.fastq.gz
out_R2_001.fastq.gz
out_abundance_transcripts.tsv
out_abundance_genes.tsv
{% endhighlight %}

### Simulate RNA sequencing with custom expression profiles

By default, **Sandy** simulates RNA sequencing raffling transcripts according to their lengths.
It is also possible to simulate RNA data that reflects the expression (abundance) of transcripts or 
genes in a particular tissue. For this purpose, built-in **expression matrices** were created from the gene
expression profiles of 54 tissues from the [GTExV8](https://www.gtexportal.org/home/) project.

You can select an expression profile with the `--expression-matrix` option. For example, let's
simulate an RNA-Seq for liver tissue:

{% highlight shell_session %}
$ sandy transcriptome --expression-matrix liver my_transcripts.fa
{% endhighlight %}

To see all available expression profiles, run:

{% highlight shell_session %}
$ sandy expression
{% endhighlight %}

## Customize simulation models

Users can include their own models of **sequencing quality**, **expression profiles** and **genomic variations**
in order to adapt the simulation to their needs.

### Sequencing quality

To add a custom sequencing quality profile to **Sandy**, you should provide a file in `fastq` format or 
a file containing only the ASCII-encoded phred-scores, as in this example:

{% highlight shell_session %}
$ cat my_qualities.txt
{% endhighlight %}

{% highlight text %}
BECGF@F@DEBIDBE@DCC?HFH?BBB?H@FEEIFDCCECCCIGDIDI?@?CCC?AE?EC?F?@FB;<9<>9:599=>7:57614,30,440&"!***)#
@DCGIDBDECIHIG@FII?G?GCAD@BFECDCEF?H?GIHE?@GEECBCIHCABAFHDFAHBEBEB:5575678=75>657673-14,.113#"()#&)$
F?B@@DFAHIDD?EBFADICBFABCBBAHFCGF@@@?DEIAIEAFCEADC?B@IB?BIEABIBG@C<:;96<968:>::;778,+0203-3,#&'$$#&!
...
{% endhighlight %}

And with the command, you can add your custom profile to **Sandy**:

{% highlight shell_session %}
$ sandy quality add --verbose --quality-profile new_quality my_qualities.txt
{% endhighlight %}

### Expression profiles

To add a custom expression profile to **Sandy**, you should provide a file containing an expression matrix with two columns.
The first column contains the transcript or gene ids and the second column contains raw counts. Counts will be treated as 
weights. Example:

{% highlight shell_session %}
$ cat my_custom_expression_matrix.txt
{% endhighlight %}

{% highlight text %}
#feature	count
ENST00000000233.9	2463
ENST00000000412.7	2494
ENST00000000442.10	275
ENST00000001008.5	5112
ENST00000001146.6	637
ENST00000002125.8	660
ENST00000002165.10	478
ENST00000002501.10	57
ENST00000002596.5	183
...
{% endhighlight %}

And with the command, you can add your custom profile to **Sandy**:

{% highlight shell_session %}
$ sandy expression add --verbose --expression-matrix new_tissue my_custom_expression_matrix.tsv
{% endhighlight %}

### Genomic variations

A genomic variation may be represented by a genomic position (seqid, position), a reference sequence
at that position, an alternate sequence and a genotype (homozygous or heterozygous). To add a custom 
set of genomic variations to **Sandy**, you should provide a vcf file or a custom file. 

For `vcf` files, the user should point out the sample present in the vcf header and then its column will be used to extract
the genotype. If the user does not pass the option `--sample-name`, then **Sandy** will use the first sample. Example:

{% highlight shell_session %}
$ cat my_variations.vcf
{% endhighlight %}

{% highlight text %}
##fileformat=VCFv4.3
...
#CHROM POS     ID    REF ALT   QUAL FILTER INFO        FORMAT NA001 NA002
chr20  14370   rs81  G   A     29   PASS   NS=3;DP=14  GT     0/1   0/0
chr20  17330   rs82  T   AAA   3    PASS   NS=3;DP=20  GT     1/1   0/0
chr20  110696  rs83  A   GTCT  10   PASS   NS=2;DP=11  GT     0/1   1/1
...
{% endhighlight %}

In the `my_variations.vcf` file, if you do not point out sample `NA002` by passing the
option `--sample-name=NA002`, the sample `NA001` will be used by default.

Alternatively, you may provide a genomic variation file, which is a representation of a reduced VCF, that is, without the 
columns: *QUAL*, *FILTER*, *INFO* and *FORMAT*. There is only one *SAMPLE* column with the genotype for the entry in
the format *HO* for homozygous and *HE* for heterozygous. See the example bellow:

{% highlight shell_session %}
$ cat my_variations.txt
{% endhighlight %}

{% highlight text %}
#seqid  position id        reference alternate	genotype
chr20   14370    rs81      G         A          HE
chr20   17330    rs82      T         AAA        HO
chr20   110696   rs83      A         GTCT       HE
{% endhighlight %}

And with the command, you can add the set of genomic variations to **Sandy**:

{% highlight shell_session %}
$ sandy variation add --verbose --genomic-variation=my_variations my_variations.txt
{% endhighlight %}

## Customize sequence identifiers

The sequence identifier, as the name implies, is a string that identifies a biological sequence (usually
nucleotides) within sequencing data. For example, the `fasta` format includes the sequence identifier
always after the `>` character at the beginning of the line; the `fastq` format always includes it after
the `@` character at the beginning of the line; the `sam` format uses the first column (called the
*query template name*).

| Sequence identifier | File format |
| :-- | :-: |
| \>**MYID and Optional information**<br />ATCGATCG | `fasta` |
| @**MYID and Optional information**<br />ATCGATCG<br />+<br />ABCDEFGH | `fastq` |
| **MYID** 99 chr1 123456 20 8M chr1 123478 30 ATCGATCG ABCDEFGH | `sam` |

Sequence identifiers may be customized in **Sandy** output using a format string passed by the user. This format
is a combination of literal and escaped characters, in a similar fashion to that used in C programming
language’s `printf` function.

For example, simulating a paired-end sequencing you can add the read length, read position and mate
position to all sequence identifiers with the following format:

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

## Make your simulations reproducible

**Sandy** comes with the option `--seed` which receives an integer and is used to initiate the random number
generator. The ability to set a *seed* is useful for those who want reproducible simulations. Pay attention
to the number of jobs (`--jobs`) set, because each job receives a different seed calculated from the *main seed*.
So, for reproducibility, the same seed set before needs the same number of jobs set before as well.

Obviously the user also needs to use the same options for the simulation type, sequencing type, quality profile,
expression matrix, genomic variation, number of reads, coverage and the file with the reference sequences.

So, let's test the reproducibility with the following examples:

### Reproducibility in genome

Let's make the same simulation twice and compare them:

{% highlight shell_session %}
$ sandy genome -v -t single-end -q nextseq_85 -j 5 -s 1717 -c 1 -a NA12878_hg38_chr17 -O fastq -o my_sim1/ chr17.fa
{% endhighlight %}

{% highlight shell_session %}
$ sandy genome -v -t single-end -q nextseq_85 -j 5 -s 1717 -c 1 -a NA12878_hg38_chr17 -O fastq -o my_sim2/ chr17.fa
{% endhighlight %}

Comparing both the results:

{% highlight shell_session %}
$ diff -s my_sim1/out_R1_001.fastq my_sim2/out_R1_001.fastq
{% endhighlight %}

And you should receive the message:

{% highlight shell_session %}
Files my_sim1/out_R1_001.fastq and my_sim2/out_R1_001.fastq are identical
{% endhighlight %}

### Reproducibility in transcriptome

in the same way as the examples above for genome, you can test the reproducibility with:

{% highlight shell_session %}
$ sandy transcriptome \
    -v \
    -t paired-end \
    -q hiseq_101 \
    -j 5 \
    -s 1717 \
    -n 1000000 \
    -f liver \
    -O fastq \
    -o my_sim1/ \
    gencode.v40.transcripts.fa.gz
{% endhighlight %}

{% highlight shell_session %}
$ sandy transcriptome \
    -v \
    -t paired-end \
    -q hiseq_101 \
    -j 5 \
    -s 1717 \
    -n 1000000 \
    -f liver \
    -O fastq \
    -o my_sim2/ \
    gencode.v40.transcripts.fa.gz
{% endhighlight %}

Comparing the simulations for R1:

{% highlight shell_session %}
$ diff -s my_sim1/out_R1_001.fastq my_sim2/out_R1_001.fastq
{% endhighlight %}

And you should receive the message:

{% highlight shell_session %}
Files my_sim1/out_R1_001.fastq and my_sim2/out_R1_001.fastq are identical
{% endhighlight %}

Comparing the simulations for R2

{% highlight shell_session %}
$ diff -s my_sim1/out_R2_001.fastq my_sim2/out_R2_001.fastq
{% endhighlight %}

And you should receive the message:

{% highlight shell_session %}
Files my_sim1/out_R2_001.fastq and my_sim2/out_R2_001.fastq are identical
{% endhighlight %}

## Persistently customize simulation models with Docker

**Sandy** *expression matrix*, *quality profile* and *structural variation* patterns are stored within
docker container, that is, any database changes during runtime will last as long as the container is
not removed.

A named Docker volume or a mounted host directory should be used in order to keep your changes to the
database. If our container detects that the path `/sandy/db` is mounted, then the database
`/sandy/db/db.sqlite3` will be used instead of the default database. In the same way, if there is no
database `db.sqlite3` inside the mounted path `/sandy/db/`, then the default database will be copied to
`/sandy/db/` and used consecutively.

**Named volume**

`sandy_db` volume will be created at first run and will persist after container deletion.

{% highlight shell_session %}
$ docker run \
    --rm \
    -v sandy_db:/sandy/db \
    galantelab/sandy
{% endhighlight %}

You can verify the created volume with the commands:

{% highlight shell_session %}
$ docker volume ls
{% endhighlight %}

And in more detail with the command:

{% highlight shell_session %}
$ docker volume inspect sandy_db
{% endhighlight %}

**Mounted directory**

`/path/to/DB` will receive the default database at first run and any further changes will be stored in it.

{% highlight shell_session %}
$ docker run \
    --rm \
    -v /path/to/DB:/sandy/db \
    galantelab/sandy
{% endhighlight %}

Now, verify the directory `/path/to/DB`. You should find the file `db.sqlite3`.

As you add your custom patterns to **Sandy**, the alterations will be kept safely outside the container.

### Add custom sequencing quality profiles

{% highlight shell_session %}
$ docker run \
    --rm \
    -v /path/to/quality_profile.txt:/quality_profile.txt \
    -v sandy_db:/sandy/db \
    galantelab/sandy quality add -q new_profile /quality_profile.txt
{% endhighlight %}

Check the new quality profile at `sandy_db`:

{% highlight shell_session %}
$ docker run --rm -v sandy_db:/sandy/db galantelab/sandy quality
{% endhighlight %}

### Add custom expression profiles

{% highlight shell_session %}
$ docker run \
    --rm \
    -v /path/to/tissue_counts.txt:/tissue_counts.txt \
    -v sandy_db:/sandy/db \
    galantelab/sandy expression add -f new_tissue /tissue_counts.txt
{% endhighlight %}

Check the new expression matrix at `sandy_db`:

{% highlight shell_session %}
$ docker run --rm -v sandy_db:/sandy/db galantelab/sandy expression
{% endhighlight %}

### Add custom genomic variations

{% highlight shell_session %}
$ docker run \
    --rm \
    -v /path/to/sv.txt:/sv.txt \
    -v sandy_db:/sandy/db \
    galantelab/sandy variation add -a new_sv /sv.txt
{% endhighlight %}

Check the new structural variation at `sandy_db`:

{% highlight shell_session %}
$ docker run --rm -v sandy_db:/sandy/db galantelab/sandy variation
{% endhighlight %}
