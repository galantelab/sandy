FROM perldocker/perl-tester:5.36 AS builder

COPY . /sandy

WORKDIR /sandy

RUN set -e; \
    \
    if [[ -f Makefile.PL ]]; then  \
      cpanm -nq -L /app ./; \
    else \
      dzil authordeps --missing | grep -v '^inc::' | cpanm -nq; \
      dzil build --no-tgz --in build; \
      cpanm -nq -L /app ./build; \
    fi

FROM perl:5.36.0-slim

LABEL maintainer="tmiller@mochsl.org.br"

COPY --from=builder /app/lib/perl5/ /usr/local/lib/perl5/vendor_perl/5.36.0/
COPY --from=builder /app/bin/sandy /usr/local/bin/
COPY --from=builder /sandy/docker/run_sandy.sh /usr/local/bin/

ENTRYPOINT ["run_sandy.sh"]
