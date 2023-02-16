FROM perl:5.36.0

LABEL maintainer="tmiller@mochsl.org.br"

ENV SANDY_ROOT="/sandy"

COPY . ${SANDY_ROOT}

RUN cd ${SANDY_ROOT} \
	&& cpanm --notest --quiet Dist::Zilla \
	&& dzil authordeps --missing | grep -v '^inc::' | cpanm --notest --quiet \
	&& dzil build --no-tgz --in build \
	&& cpanm --notest --quiet ${SANDY_ROOT}/build

ENTRYPOINT ["sandy"]
