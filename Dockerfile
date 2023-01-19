FROM thevlang/vlang:alpine-dev

RUN apk add --no-cache jq

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
