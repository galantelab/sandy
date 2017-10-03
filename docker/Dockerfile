FROM perl:latest

LABEL \
	maintainer="Thiago Miller" \
	email="<tmiller@mochsl.org.br>" \
	description="Docker image for the simulate_reads project"

RUN cpanm App::SimulateReads

WORKDIR /tmp
USER nobody
ENTRYPOINT ["simulate_reads"]
