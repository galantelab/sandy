package App::Sandy::Command::Citation;
# ABSTRACT: citation command class. Print citation

use App::Sandy::Base 'class';

extends 'App::Sandy::CLI::Command';

# VERSION

sub validate_args {
	my ($self, $args) = @_;
	die "Too many arguments: '@$args'\n" if @$args;
}

sub execute {
	print <<'EOP';
You can cite all versions by using the following DOI:

	Thiago Miller. (2018, May 6).
	galantelab/sandy: A straightforward and complete next-generation sequencing read simulator.
	Zenodo. http://doi.org/10.5281/zenodo.1241587

	BibTeX:

	@misc{thiago_miller_sandy,
		author       = {Thiago Miller},
		title        = {galantelab/sandy: A straightforward and complete next-generation sequencing read simulator},
		month        = may,
		year         = 2018,
		doi          = {10.5281/zenodo.1241587},
		url          = {https://doi.org/10.5281/zenodo.1241587}
	}

This DOI represents all versions, and will always resolve to the latest one.
If you want to cite a specific version, please point to https://zenodo.org/record/1241587

EOP
}
