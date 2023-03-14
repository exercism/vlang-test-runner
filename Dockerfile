FROM thevlang/vlang:alpine-dev

# Increment this value to force rebuilding of the image
ARG CACHE_BUSTER=1

RUN apk add --no-cache jq sed

WORKDIR /tmp/sample
COPY pre-compile/ ./
RUN v -stats test run_test.v

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
