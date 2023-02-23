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

# These two are necessary to keep bmake happy
sub xs_c {
	my $self = shift;
	my $ret = $self->SUPER::xs_c(@_);
	$ret =~ s/\$\*\.xs/\$</g;
	$ret =~ s/\$\*\.c\b/\$@/g;
	return $ret;
}

sub c_o {
	my $self = shift;
	my $ret = $self->SUPER::c_o(@_);
	$ret =~ s/\$\*\.c\b/\$</g;
	$ret =~ s/\$\*\$\(OBJ_EXT\)/\$@/g;
	return $ret;
}

sub const_cccmd {
	my $ret = shift->SUPER::const_cccmd(@_);
	return q{} unless $ret;

	$ret .= ' -o $@';

	return $ret;
}

# Fix shared object path
sub constants {
	my $self = shift;
	my $ret = $self->SUPER::constants(@_);
	$ret =~ s|(?<=\nFULLEXT).*\n| = App/Sandy/RNG\n|;
	$ret =~ s|(?<=\nBASEEXT).*\n| = RNG\n|;
	return $ret;
}

sub postamble {
	my $self = shift;
	my @ret = File::ShareDir::Install::postamble($self);

	my $cmd = q{
# --- App::Sandy custom postamble section:
LFS_URL = https://media.githubusercontent.com/media/galantelab/sandy/master/share/assets/db.sqlite3
INST_DB = $(INST_LIB)/auto/share/dist/$(DISTNAME)
INST_SHARE = blib/share
INSTALLSHARE = /usr/share
DESTINSTALLSHARE = $(DESTDIR)$(INSTALLSHARE)
PERM_DB_DIR = 0777
PERM_DB = 666

pure_perl_install :: all
	-$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLPRIVLIB)/auto/share/dist/$(DISTNAME)"
	-$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLPRIVLIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"
	-$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLARCHLIB)/auto/share/dist/$(DISTNAME)"
	-$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLARCHLIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"

pure_site_install :: all
	-$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLSITELIB)/auto/share/dist/$(DISTNAME)"
	-$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLSITELIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"
	-$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLSITEARCH)/auto/share/dist/$(DISTNAME)"
	-$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLSITEARCH)/auto/share/dist/$(DISTNAME)/db.sqlite3"

pure_vendor_install :: all
	-$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLVENDORLIB)/auto/share/dist/$(DISTNAME)"
	-$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLVENDORLIB)/auto/share/dist/$(DISTNAME)/db.sqlite3"
	-$(NOECHO) $(CHMOD) $(PERM_DB_DIR) "$(DESTINSTALLVENDORARCH)/auto/share/dist/$(DISTNAME)"
	-$(NOECHO) $(CHMOD) $(PERM_DB) "$(DESTINSTALLVENDORARCH)/auto/share/dist/$(DISTNAME)/db.sqlite3"

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

config :: config_lfs
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_DB)'\'')' -- \
		'share/assets/db.sql' '$(INST_DB)/db.sql' \
		'share/assets/db.sqlite3' '$(INST_DB)/db.sqlite3'

config ::
	$(NOECHO) $(ABSPERLRUN) -MExtUtils::Install -e 'pm_to_blib({@ARGV}, '\''$(INST_SHARE)'\'')' -- \
		'share/completions/sandy-completion.bash' '$(INST_SHARE)/bash-completion/completions/sandy' \
		'share/completions/sandy-completion.zsh' '$(INST_SHARE)/zsh/site-functions/_sandy'

.PHONY : config_lfs
config_lfs :
ifndef GITHUB_ACTIONS_CI
	$(NOECHO) if ! perl -E 'exit((-s $$ARGV[0] && -B $$ARGV[0])?0:1)' 'share/assets/db.sqlite3'; \
	then \
		echo 'Database share/assets/db.sqlite3 is not a binary file.'; \
		echo 'Maybe it is a git-lfs pointer, so I will try to download it for you'; \
		perl -MLWP::Simple -e 'getprint "$(LFS_URL)"' > './db.sqlite3'; \
		if ! perl -E 'exit((-s $$ARGV[0] && -B $$ARGV[0])?0:1)' './db.sqlite3'; \
		then \
			echo 'Something went wrong. Abort.'; \
			exit 1; \
		fi; \
		mv './db.sqlite3' 'share/assets/db.sqlite3'; \
	fi
endif

# --- END: App::Sandy custom postamble section
};

	push @ret, $cmd;
	return join "\n", @ret;
}
TEMPLATE

	return $template;
};

override _build_WriteMakefile_args => sub {
	my ($self) = @_;
	my (@object, %xs);

	for my $xs ( glob "xs/*.xs" ) {
		( my $c = $xs ) =~ s/\.xs$/.c/i;
		( my $o = $xs ) =~ s/\.xs$/\$(OBJ_EXT)/i;

		$xs{$xs} = $c;
		push @object, $o;
	}

	for my $c ( glob "xs/*.c" ) {
		( my $o = $c ) =~ s/\.c$/\$(OBJ_EXT)/i;
		push @object, $o;
	}

	return +{
			%{ super() },
			INC       => '-I. -Ixs',
			LIBS      => [ '-lm' ],
			OBJECT    => join( q{ }, @object ),
			XS        => \%xs,
			clean     => { FILES => join( q{ }, @object ) },
	};
};

__PACKAGE__->meta->make_immutable;

1;
