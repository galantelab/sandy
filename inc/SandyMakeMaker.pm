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

sub postamble {
	my $self = shift;
	my @ret = File::ShareDir::Install::postamble($self);

	my $cmd = q{
# --- App::Sandy custom postamble section:
INST_SHARE = blib/share
INSTALLSHARE = /usr/share
DESTINSTALLSHARE = $(DESTDIR)$(INSTALLSHARE)

pure_perl_install :: all
	-$(NOECHO) $(MOD_INSTALL) \
		read "$(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLARCHLIB)/auto/$(FULLEXT)/.packlist" \
		"$(INST_SHARE)" "$(DESTINSTALLSHARE)"

pure_site_install :: all
	-$(NOECHO) $(MOD_INSTALL) \
		read "$(SITEARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLSITEARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_SHARE)" "$(DESTINSTALLSHARE)"

pure_vendor_install :: all
	-$(NOECHO) $(MOD_INSTALL) \
		read "$(VENDORARCHEXP)/auto/$(FULLEXT)/.packlist" \
		write "$(DESTINSTALLVENDORARCH)/auto/$(FULLEXT)/.packlist" \
		"$(INST_SHARE)" "$(DESTINSTALLSHARE)"

config ::
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_SHARE)'\'')' -- \
		'completions/sandy-completion.bash' '$(INST_SHARE)/bash-completion/completions/sandy'

config ::
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_SHARE)'\'')' -- \
		'completions/sandy-completion.zsh' '$(INST_SHARE)/zsh/site-functions/_sandy'

# --- END: App::Sandy custom postamble section
};

	push @ret, $cmd;
	return join "\n", @ret;
}
TEMPLATE

	return $template;
};

__PACKAGE__->meta->make_immutable;

1;
