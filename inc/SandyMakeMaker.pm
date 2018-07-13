package inc::SandyMakeMaker;
# ABSTRACT: Install bash/zsh completion for sandy

use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

override _build_MakeFile_PL_template => sub {
	my $self = shift;
	my $template = super();

	$template .= << 'TEMPLATE';
package MY;

use File::ShareDir::Install;

sub install {
	my $self = shift;
	my $inherited = $self->SUPER::install(@_);
	my $new;
	for (split( "\n", $inherited)) {
		if ( /^install :: / ) {
			$_ .= " support_files_install";
		} elsif (/^uninstall ::/) {
			$_ .= " support_files_uninstall";
		}
		$new .= "$_\n";
	}
	return $new;
}

sub postamble {
	my $self = shift;
	my @ret = File::ShareDir::Install::postamble($self);

	my $cmd = q{
SHELL := /bin/bash
support_files_install :
	$(NOECHO) [ `id -u` = 0 ] \
		&& $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)'\'')' -- \
			'completions/sandy-completion.bash' '/usr/share/bash-completion/completions/sandy' \
		&& $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_LIB)'\'')' -- \
			'completions/sandy-completion.zsh' '/usr/share/zsh/site-functions/_sandy'

support_files_uninstall :
	$(NOECHO) rm -f '/usr/share/bash-completion/completions/sandy' \
		'/usr/share/zsh/site-functions/_sandy'
};

	push @ret, $cmd;
	return join "\n", @ret;
}
TEMPLATE

	return $template;
};

__PACKAGE__->meta->make_immutable;

1;
