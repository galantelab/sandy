## Welcome to Sandy simulator! ##

![logo.png](sandy_logo.png)

**Let's make a simulation today???**

If you're looking for a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given FASTA file or expression matrix file,
then *Sandy* is your choice!



### Contents at a Glance ###

1. [Introduction](#intro)
2. [Installation](#install)
3. [Usage and Option summary](#summ)
	1. [General](#general)
    2. [Command `genome`, its options and examples](#genome)
    3. [Command `transcriptome`, its options and examples](#transcriptome)
    4. [Command `custom`, its options and examples](#custom)
    5. [Command `quality`, its options and examples](#quality)
    6. [Command `expression`, its options and examples](#expression)
    7. [Command `help`, its options and examples](#help)
4. [A case study example](#expl)
5. [Aknowledgements](#aknw)
6. [Author](#author)
7. [Copyright and License](#copy)



### Introduction {#intro} ###

Project *Sandy* is in it's 0.15 version and has earned enough maturity to
simulate some realistic features, among these:
* Simulate reads from genomic FASTA-files.
* Simulate reads from transcriptomic data, based on expression matrix files.
* Ready included databases for *quality profiles* and *expression matrixes*.
* Import and record your own *expression matrixes* and *quality profiles* to
simulate future data.



### Installation {#install} ###

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

For more details, see the INSTALL file on *Sandy's* GitHub [repository](https://github.com/galantelab/simulate_reads).



### Usage and Option summary {#summ} ###

1. General syntax {#general}

	**Usage:**
	```bash
		$ sandy [options]
	```
	or
	```bash
		$ sandy help <command>
	```
	or even
	```bash
		$ sandy <command> [options] <FILEs>
	```
	where there are basically two options for general help, five main commands
	with their own inner options, and a specific `help` command for each of the
	main commands. See:
	
	Options							| Description
	-------							| -----------
	  -h, --help					| brief help message
	  -M, --man						| full documentation
	**Help commands**				|.
	  help							| show application or command-specific help
	  man							| show application or command-specific documentation
	**Main commands**				|.
	  genome						| simulate genome sequencing
	  transcriptome					| simulate transcriptome sequencing
	  custom						| simulate custom sequencing
	  quality						| manage quality profile database
	  expression					| manage expression-matrix database

2. The `genome` command {#genome}

	Use it to generate simulated FASTAq-files from a given FASTA-file.
	The `genome` command sets these default options for a genome sequencing simulation:
	* The strand is **randomly** chosen;
	* The number of reads is calculated by the coverage;
	* The chromossomes are raffled following a weighted raffle with the
	sequence length as the bias;
	
	**USAGE:**
	```bash
		$ sandy genome [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy genome -h` or
	even `sandy help genome` commands.
	At least one fasta-file must be given as the `<FILEs>` term. The results
	will be one or two fastaq-files, depending on the sequencing-type option,
	`-t`, for single-ended or paired-ended reads, and an additional reads-count
	file.
	
	Options							| Description
	-------							| -----------
      -h, --help					| brief help message
      -M, --man						| full documentation
      -v, --verbose					| print log messages
      -p, --prefix					| prefix output [default:"out"]
      -o, --output-dir				| output directory [default:"."]
      -i, --append-id				| append to the defined template id [Format]
      -I, --id						| overlap the default template id [Format]
      -j, --jobs					| number of jobs [default:"1"; Integer]
      -z, --gzip					| compress output file
      -s, --seed					| set the seed of the base generator [default:"time()"; Integer]
      -c, --coverage				| fastq-file coverage [default:"8", Number]
      -t, --sequencing-type			| single-end or paired-end reads [default:"paired-end"]
      -q, --quality-profile			| illumina sequencing system profiles [default:"hiseq"]
      -e, --sequencing-error		| sequencing error rate [default:"0.005"; Number]
      -r, --read-size				| the read size [default:"101"; Integer]
      -m, --fragment-mean			| the fragment mean size for paired-end reads [default:"300"; Integer]
      -d, --fragment-stdd			| the fragment standard deviation size for paired-end reads [default:"50"; Integer]
	
	**Some examples:**
	
	The command:
	```bash
		$ sandy genome --verbose --sequencing-type=paired-end --coverage=20 hg38.fa 2> sim.log
	```
	ou, with an equal effect:
	```bash
		$ sandy genome -v -t paired-end -c 20 hg38.fa 2> sim.log
	```
	will produce two FASTAq-files (sequencing-type default is "paired-end"),
	both with a coverage of 20x (coverage default is 8), and a simple
	text reads-count file in a tab separated fashion.

	**Note:** If you use the option `-v`, by default, the log messages will be
	directed to the standard error so, in the example above, it was redirected
	to a file. Whithout the `-v` option, only errors messages will be printed.
	
	For reproducibility, you can set an integer seed for the random raffles
	with the `-s` option (seed default is environment `time()` value),
	for example:
	```bash
		$ sandy genome -s 1220 my_fasta.fa
	```
	
	To simulate reads with a ready database registered specific quality
	profile other than default's one, type, for example:
	```bash
		$ sandy genome --quality-profile=hiseq_101 hg19.fa
	```
	See the [quality profile](#howto) section to know how you can register a
	new profile.
	
	The sequence identifier is the first and third line of a FASTq entry
	beggining with a **@** token, for a read identifier, and a **+**,
	for a quality identifier.
	*Sandy* has the capacity to customize it, with a format string passed by
	the user. This format is a combination of literal and escaped characters,
	in a similar fashion used in **C** programming language's `printf`
	function.
	For example, let's simulate a paired-end sequencing and put into it's
	identifier the read length, read position and mate position:
	```bash
		$ sandy genome -s 123 --id="%i.%U read=%c:%t-%n mate=%c:%T-%N length=%r" hg38.fa
	```
	In this case, results would	be:
	```bash
	>$ sandy genome -s 123 --id="%i.%U read=%c:%t-%n mate=%c:%T-%N length=%r" hg38.fa
	> ==> Into R1
	> @SR.1 read=chr6:979-880 mate=chr6:736-835 length=100
	> ...
	> 
	> ==> Into R2
	> @SR.1 read=chr6:736-835 mate=chr6:979-880 length=100
	> ...
	```
	
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

3. The `transcriptome` command {#transcriptome}

	Use it to generate simulated FASTAq files from a given FASTA file,
	according to an expression profile matrix file.
	The `transcriptome` command sets these default options for a transcriptome
	sequencing simulation as well:
	* Choose the **Minus** strand;
	* The number of reads is directly passed;
	* The genes/transcripts are raffled following the expression matrix;
	
	**USAGE:**
	```bash
		$ sandy transcriptome [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy transcriptome -h` or
	even `sandy help transcriptome` commands.
	
	Options							| Description
	-------							| -----------
	  -h, --help					| brief help message
      -M, --man						| full documentation
      -v, --verbose					| print log messages
      -p, --prefix					| prefix output [default:"out"]  
	  -f, --expression-matrix		| set the expression matrix [default: none]
      -o, --output-dir				| output directory [default:"."]
      -i, --append-id				| append to the defined template id [Format]
      -I, --id						| overlap the default template id [Format]
      -j, --jobs					| number of jobs [default:"1"; Integer]
      -z, --gzip					| compress output file
      -s, --seed					| set the seed of the base generator [default:"time()"; Integer]
      -n, --number-of-reads			| set the number of reads [default:"1000000", Integer]
      -t, --sequencing-type			| single-end or paired-end reads [default:"paired-end"]
      -q, --quality-profile			| illumina sequencing system profiles [default:"hiseq"]
      -e, --sequencing-error		| sequencing error rate [default:"0.005"; Number]
      -r, --read-size				| the read size [default:"101"; Integer]
      -m, --fragment-mean			| the fragment mean size for paired-end reads [default:"300"; Integer]
      -d, --fragment-stdd			| the fragment standard deviation size for paired-end reads [default:"50"; Integer]
	
	**Some examples:**
	
	The command:
	```bash
		$ sandy transcriptome --verbose --number-of-reads=1000000 --expression-matrix=brain_cortex gencode_pc_v26.fa.gz
	```
	or, equivalently
	```bash
		$ sandy transcriptome -v -n 1000000 -f brain_cortex gencode_pc_v26.fa.gz
	```

4. The `custom` command{#custom}

	This is the most versatile command to procuce FASTAq-files,
	but the user must deal whit a greater number os options.
	
	**Usage:**
	```bash
		$ sandy custom [options] <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy custom -h` or
	even `sandy help custom` commands.
	
	Options							| Description
	-------							| -----------
	  -h, --help					| brief help message
      -M, --man						| full documentation
      -v, --verbose					| print log messages
      -p, --prefix					| prefix output [default:"out"]  
      -o, --output-dir				| output directory [default:"."]
      -i, --append-id				| append to the defined template id [Format]
      -I, --id						| overlap the default template id [Format]
      -j, --jobs					| number of jobs [default:"1"; Integer]
      -z, --gzip					| compress output file
      -s, --seed					| set the seed of the base generator [default:"time()"; Integer]
      -c, --coverage				| fastq-file coverage [default:"8", Number]
      -n, --number-of-reads			| directly set the number of reads [Integer]
      -t, --sequencing-type			| single-end or paired-end reads [default:"paired-end"]
      -q, --quality-profile			| illumina sequencing system profiles [default:"hiseq"]
      -e, --sequencing-error		| sequencing error rate [default:"0.005"; Number]
      -r, --read-size				| the read size [default:"101"; Integer]
      -m, --fragment-mean			| the mean size fragments for paired-end reads [default:"300"; Integer]
      -d, --fragment-stdd			| the standard deviation for fragment sizes [default:"50"; Integer]
      -b, --strand-bias				| which strand to be used: plus, minus and random [default:"random"]
      -w, --seqid-weight			| seqid raffle type: length, same, file [default: "length"]
      -f, --expression-matrix		| an expression-matrix entry from database, when seqid-weight=count
	
	**Some examples**
	

5. The `quality` command {#quality}

	Use it to manage your quality profile database.
	You can add or remove your own expression profiles in the builtin database
	to make your simulations more realistic based on real experimental data.
	Or you can even clean it up to restore the vendor's original entries state.
	By default, *Sandy* uses a poisson distribution when compiling the
	quality entries, but like many other features, this behavior can be
	overrided by the user.
	
	**Usage:**
	```bash
		$ sandy quality [options] <sub-command> <FILEs>
	```
	whose options' exaustive list can be consulted by `sandy quality -h` or
	even `sandy help quality` commands.
	
	Options							| Description
	-------							| -----------
	  -h, --help					| brief help message
      -M, --man						| full documentation
    **Sub-commands**				|.
      add							| add a new quality profile to database
      remove						| remove an user quality profle from database
      restore						| restore the database
	
	**Some examples:**
	
	To list the quality profiles already registered in the builtin database,
	you can simply type:
	```bash
		$ sandy quality
	```
	and all entries will be shown.
	
	So, to register a new probabilistic quality profile, called, for example,
	'my_profile.txt', to be used in the simulation of your FASTA-file.
	You can type:
	```bash
		$ sandy quality add my_profile.txt
	```
	This quality profile can be either a FASTAq file or a plain text file in
	a tab separated fashion (quality profile defaut density function is
	"Poisson").
	
	**Note:** Before the new entry can appear in the database's list, the new
	profile needs to be validated, and if it can't, an error message will
	be show. Sandy prevent's you before overwrite an existing entry.
	
	Sometimes you will need to update or delete some quality profile entry
	('my_profile.txt' for example) in the database. In this situation, you can
	remove some actual entry and register a newer one, like this:
	```bash
		$ sandy quality remove my_profile.txt
	```
	Sandy will refuse to remove any vendor's original entry from the database.
	
	And, there could be times when you would want to reset all the database to
	its original state. It's a very simple command:
	```bash
		$ sandy quality restore
	```
	Note that this is a dangerous command and Sandy will warn you about it
	before make the restoration in fact.
	
	**Note:** Sandy already comes with one quality profile based on the Poisson
	probabilistic curve, as described by the literature
	([illumina, 2018](https://www.illumina.com/content/dam/illumina-marketing/documents/products/technotes/technote_understanding_quality_scores.pdf)).

6. The `expression` command {#expression}

	Use it to manage your matrix-expression database.
	You can add or remove your own expression profiles in the builtin database.
	Or even clean it up to restore the vendor's original entries state.
	
	**Usage:**
	```bash
		$ sandy expression <sub-command> [options] <FILEs>
	```
	whose options' and sub-commands' exaustive list can be consulted by
	`sandy expression -h` or even `sandy help expression` commands.
	
	Options							| Description
	-------							| -----------
	  -h, --help					| brief help message
      -M, --man						| full documentation
    **sub-commands**				|.
      add							| add a new expression-matrix to database
      remove						| remove an user expression-matrix from database
      restore						| restore the database
	
	**Some examples:**
	
	To list the expression files already registered in the builtin database,
	you can simply type:
	```bash
		$ sandy expression
	```
	and all entries will be shown.
	Sandy already comes with expression-matrixes for 18 kinds of tissues
	obtained from the [GETx](https://www.gtexportal.org/home/) project.
	
	But, supose you want to register a new [ponga](See here) formated
	expression-matrix file called 'my_mtx.txt', to simulate your FASTA-file
	according to a experimentally annnotated genes expression profile.
	In this case, the command bellow would solve your problem:
	```bash
		$ sandy expression add my_mtx.txt
	```
	Note that before the new entry can appear in the database's list, the new
	matrix file needs to be validated, and if it can't, an error message will
	be show. Sandy prevent's you before overwrite an existing entry.
	
	Sometimes you will need to update or delete some expression-matrix entry
	('my_mtx.txt' for example) in the database. In this situation, you can
	remove the actual entry and register a newer one, like this:
	```bash
		$ sandy expression remove my_mtx.txt
	```
	Sandy will refuse to remove any vendor's original entry from the database.
	
	And, there could be times when you would want to reset all the database to
	its original state. It's a very simple command:
	```bash
		$ sandy expression restore
	```
	Note that this is a dangerous command and Sandy will warn you about it
	before make the restoration in fact.

7. The `help` command {#help}

	**Usage:**
	
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


### A case study example ###


### Aknowledgements ###



### Author ###

Thiago L. A. Miller
[<tmiller@mochsl.org.br>](tmiller@mochsl.org.br)



### Copyrirht and License ###

This software is Copyright (c) 2018 by Teaching and Research Institute from Sírio-Libanês Hospital.
This is free software, licensed under:

`The GNU General Public License, Version 3, June 2007`
