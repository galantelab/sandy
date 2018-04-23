## Welcome to Sandy simulator! ##

![logo.png](sandy_logo.png)

**Let's make a simulation today???**

If you're looking for a bioinformatics tool that provides a simple engine to generate
single-end/paired-end reads from a given fasta file or expression matrix file,
then *Sandy* is your choice!



### Contents at a Glance ###

1. [Introduction](#markdown-header-introduction)
2. Installation
3. Usage and Option summary
	1. General
    2. Command `genome`, its options and examples
    3. Command `transcriptome`, its options and examples
    4. Command `custom`, its options and examples
    5. Command `quality`, its options and examples
    6. Command `expression`, its options and examples
    7. Command `help`, its options and examples
4. A case study example
5. Aknowledgements
6. Author
7. Copyright and License



### <a name="intro"></a> Introduction ###

Project *Sandy* is in it's 0.15 version and has earned enough maturity to
simulate some realistic features, among these:
* Simulate reads from genomic FASTA-files.
* Simulate reads from transcriptomic FASTAq-files.
* Simulate reads from transcriptomic data, based on expression matrix files.
* Import and record your own expression matrixes profiles to simulate future data.
* And Simulate all that for several technical replicates!



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

For more details, see the INSTALL file on *Sandy's* GitHub [repository](https://github.com/galantelab/simulate_reads).



### Usage and Option summary ###

1. The general syntax.

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

2. The `genome` command.

	Use it to generate simulated FASTAq-files from a given FASTA-file.
	
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
		$ sandy genome -t paired-end -c 20 my_fasta_file.fa
	```
	will produce two FASTAq-files (sequencing-type default is "paired-end"),
	both with a coverage of 20x (coverage default is 8), and a simple
	reads-count file in a tab separated fashion.
	
	For reproducibility, you can set an integer seed for the random raffles
	with the `-s` option (seed default is environment `time()` value),
	for example:
	```bash
		$ sandy genome -s 1220 my_fasta_file.fa
	```
	
	By default, the resulting FASTAq-files will have *Gencode*'s ID format
	style, this behavior can be overwritten with the `-i` or `-I` options with
	a formating string, like this:
	```bash
		$ sandy genome -i "%d\t%s" my_fasta_file.fa
	```
	This will produce FASTAq-files with the specified ID format style.
	
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

3. The `transcriptome` command.

	Use it to generate simulated FASTAq files from a given FASTA file,
	according to an expression profile based on an expression matrix file.
	
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
	
	But if you set a number of replicas with the `-R` option, the
	aforementioned number of resultant files will be multiplied by that number
	of replicas, like this:
	```bash
		$ sandy genome -t paired-end -R 5 my_fasta_file.fa
	```
	will produce a total of 15 files (replicas default is 1).

4. The `custom` command.

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
	
	Write...

5. The `quality` command.

	Use it to manage your quality profile database.
	You can add or remove your own expression profiles in the builtin database.
	Or even clean it up to restore the vendor's original entries state.
	
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
	Sandy already comes with one quality profile based on the Poisson
	probabilistic curve, as recommended by the literature
	([Shostner, 2015](asdcadca)).
	
	So, to register a new [ponga](See here) formated quality profile, called
	'my_profile.txt', to be used in the simulation of your FASTA-file.
	You can type:
	```bash
		$ sandy quality add my_profile.txt
	```
	Note that before the new entry can appear in the database's list, the new
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

6. The `expression` command.

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

7. The `help` command.

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
