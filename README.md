## Welcome to Sandy simulator! ##

** Let's make a simulation today??? **

If you're looking for a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given fasta file or expression matrix file,
then *Sandy* is your choice!



### Contents at a Glance ###

1. [Introduction](intro)
2. Installation
3. How to use
    1. Command `genome`, its options and examples
    2. Command `transcriptome`, its options and examples
    3. Command `custom`, its options and examples
    4. Command `quality`, its options and examples
    5. Command `expression`, its options and examples
    6. Command `help`, its options and examples
4. Aknowledgements
5. Author
6. Copyright and License



### Introduction ###

Project *Sandy* is in it's 0.14 version and has earned enough maturity to
simulate some realistic features, among these:
* Simulate reads for genomic FASTA files.
* Simulate reads for transcriptomic FASTAq files.
* Simulate reads for transcriptomic expression matrix files.
* Import and record your own expression profiles to simulate future data.
* Simulate reads for several technical replicates.



### Installation ###

You can install it by two different approaches.

1. If you already use `perl` and perl modules `cpanm`, the solution comes
in one line:
```bash
	$ cpanm App::SimulateReads
```
2. If you only have `perl`, as a last resort, you can manually install *Sandy*
through the command line by downloading the [tarball](https://github.com/galantelab/simulate_reads/archive/master.zip)
from GitHub, decompressing it and then building it, like this:
```bash
	$ wget https://github.com/galantelab/sandy/archive/sandy-master.tar.gz
	$ tar xzvf sandy-master.tar.gz
	$ cd sandy
	$ perl Makefile.PL
	$ make && make test
```
Then install it properly with:
```bash
	$ make install
```
For more datails, see the INSTALL file on *Sandy's* GitHub [repository](https://github.com/galantelab/simulate_reads).



### How to use ###

The general syntax to invoke *Sandy* is
```bash
	$ sandy <command> [options] <FILEs>
```
or
```bash
	$ sandy help <command>
```
where basically there are six general commands whose options depends on:

1. The `genome` command.

	Use it to generate simulated fastaq-files from a given fasta-file.
	
	Here is an example of the command's general syntax:
	```bash
		$ sandy genome [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy genome -h` or
	even `sandy help genome` commands.
	
	At least one fasta-file must be given as the `<FILEs>` term. The results
	will be one or two fastaq-files, depending on the sequencing-type option,
	`-t`, for single-ended or paired-ended reads, and an additional reads-count
	file, per replica. For example
	```bash
		$ sandy genome -t paired-end -c 20 my_fasta_file.fa
	```
	will produce two fastaq-files (sequencing-type default is "paired-end"), both with
	a coverage of 20x (coverage default is 8), and a simple reads-count
	file in a tab separated fashion.
	
	But if you set a number of replicas with the `-R` option, the
	aforementioned number of resultant files will be multiplied by that number
	of replicas, like this:
	```bash
		$ sandy genome -t paired-end -R 5 my_fasta_file.fa
	```
	will produce a total of 15 files (replicas default is 1).
	
	For reproducibility, you can set an integer seed for the random raffles
	with the `-s` option (seed default is `time()` value), for example:
	```bash
		$ sandy genome -s 1220 my_fasta_file.fa
	```
	
	By default, the resulting fastaq-files will have *gencode*'s ID format
	style, this behavior can be overwritten with the `-i` or `-I` options with
	a formating string, like this:
	```bash
		$ sandy genome -i "%d\t%s" my_fasta_file.fa
	```
	This will produce fastq-files with the specified ID format style.
	
	To change the sequencing quality profile, use the `-q` option and a
	string value (quality-profile default is "hiseq"):
	```bash
		$ sandy genome -q hiseq2 my_fasta_file.fa
	```
	
	You can set the size of the reads with the `-r` option and an integer
	number (reads-size default is 101):
	```bash
		$ sandy genome -r 151 my_fasta_file.fa
	```
	
	You can set the mean size of a fragment in a paired-end sequencing with
	the `-m` option and an integer number (default is 300):
	```bash
		$ sandy genome -m 300 my_fasta_file.fa
	```
	
	And you can also set the standard deviation of the size of a fragment in
	a paired-end sequencing with the `-d` option and an integer number
	(default is 50):
	```bash
		$ sandy genome -d 30 my_fasta_file.fa
	```
	
	The options above are the most frequently used ones for the `genome`
	command, but many more can be found in the *Sandy's* documentation.

2. The `transcriptome` command.

	Use it to generate simulated FASTAq files from a given FASTA file.
	
	Here is an example of the command's general syntax:
	```bash
		$ sandy transcriptome [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy transcriptome -h` or
	even `sandy help transcriptome` commands.

3. The `custom` command.

	Use it to generate simulated FASTAq files from a given FASTA file.
	
	Here is an example of the command's general syntax:
	```bash
		$ sandy custom [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy custom -h` or
	even `sandy help custom` commands.

4. The `quality` command.

	Use it to record your own expression profiles in the builtin database.
	
	Here is an example of the command's general syntax:
	```bash
		$ sandy quality [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy quality -h` or
	even `sandy help quality` commands.

5. The `expression` command.

	Use it to record your own expression profiles in the builtin database.
	
	Here is an example of the command's general syntax:
	```bash
		$ sandy expression [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy expression -h` or
	even `sandy help expression` commands.

6. The `help` command.

	To get a simple general help, you can type any of these commands:
	```bash
		$ sandy --help
	```
	or for short
	```bash
		$ sandy -h
	```
	or simply call it without any arguments.
	```bash
		$ sandy
	```
	
	But, if you need a more comprehensive explanation, you can invoke *Sandy's*
	manual:
	```bash
		$ sandy --man
	```
	or for short
	```bash
		$ sandy -M
	```
	
	For help about specific commands, its options and inputs, type:
	```bash
		$ sandy help <command>
	```
	or
	```bash
		$ sandy <command> -h
	```

And you can aways get help by consulting *Sandy's* manuals in your system's
builtin documentations with `man sandy` or `info sandy` commands.



### Aknowledgements ###



### Author ###

Thiago L. A. Miller
[<tmiller@mochsl.org.br>](tmiller@mochsl.org.br)



### Copyrirht and License ###

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.
This is free software, licensed under:

`The GNU General Public License, Version 3, June 2007`
