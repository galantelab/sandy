package inc::SandyMakeMaker;
# ABSTRACT: Install bash/zsh completion and database

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
INST_DB = $(INST_LIB)/auto/share/dist/$(DISTNAME)
INST_SHARE = blib/share
INSTALLSHARE = /usr/share
DESTINSTALLSHARE = $(DESTDIR)$(INSTALLSHARE)
PERM_DB_DIR = 0777
PERM_DB = 666

pure_perl_install :: all
	$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLPRIVLIB)/auto/share/dist/$(DISTNAME)"
	$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLPRIVLIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"

pure_site_install :: all
	$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLSITELIB)/auto/share/dist/$(DISTNAME)"
	$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLSITELIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"

pure_vendor_install :: all
	$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLVENDORLIB)/auto/share/dist/$(DISTNAME)"
	$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLVENDORLIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"

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
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_DB)'\'')' -- \
		'share/assets/db.sql' '$(INST_DB)/db.sql' \
		'share/assets/db.sqlite3' '$(INST_DB)/db.sqlite3'

config ::
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_SHARE)'\'')' -- \
		'share/completions/sandy-completion.bash' '$(INST_SHARE)/bash-completion/completions/sandy' \
		'share/completions/sandy-completion.zsh' '$(INST_SHARE)/zsh/site-functions/_sandy'

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
