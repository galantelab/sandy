---
layout: home
---

{% include title.html
  title="A straightforward and complete next-generation sequencing read simulator"
  button_name="View on GitHub"
  button_url="https://github.com/galantelab/sandy"
%}

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

<br />
