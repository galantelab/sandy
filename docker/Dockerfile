FROM perl:5.36.0

LABEL maintainer="tmiller@mochsl.org.br"

ENV SANDY_ROOT="/sandy" \
	PERL_MM_OPT="INSTALLDIRS=vendor" \
	PERL_MB_OPT="--installdirs vendor"

COPY . ${SANDY_ROOT}

RUN cd ${SANDY_ROOT} \
	&& cpanm --notest --quiet Dist::Zilla \
	&& dzil authordeps --missing | grep -v '^inc::' | cpanm --notest --quiet \
	&& dzil build --no-tgz --in build \
	&& cpanm --notest --quiet ./build \
	&& install -Dpm755 docker/run_sandy.sh /usr/local/bin/run_sandy.sh

RUN rm -rf ${SANDY_ROOT}

ENTRYPOINT ["run_sandy.sh"]
