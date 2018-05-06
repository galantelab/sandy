FROM perl:latest

LABEL \
	maintainer="Thiago L. A. Miller" \
	email="<tmiller@mochsl.org.br>" \
	description="Docker image for the sandy project"

RUN cpanm App::Sandy

USER nobody
ENTRYPOINT ["sandy"]
