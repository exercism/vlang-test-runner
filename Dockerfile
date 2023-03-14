#FROM thevlang/vlang:alpine-dev
# The official vlang docker image contains a version of V that is both well behind the
# mainstream version of V, and cannot be pinned to a known version. So, create our own.
# Ref: https://github.com/exercism/vlang-test-runner/issues/10

# Conveniently however, vlang maintain a minimal image capable of *building* V. At the
# moment that's just what we want, and allows us to specify the version of V we want
# without needing to install the dependencies.
FROM thevlang/vlang:alpine-build AS build

# The only thing left to do is build V. This is inspired by:
# https://github.com/vlang/docker/blob/master/docker/vlang/Dockerfile.alpine
# But is pinned to the recent known good version in commit:
# https://github.com/vlang/v/tree/b71c131678c56adaf3feb0cff896176326cdd043
# This produces version "V 0.3.3 b71c131"
WORKDIR /opt/vlang
RUN git clone --branch master https://github.com/vlang/v /opt/vlang && \
	git checkout b71c131678c56adaf3feb0cff896176326cdd043 && \
	make VFLAGS='-cc gcc' && \
	v -version

# Build done, so we can now return to the original task:

FROM thevlang/vlang:alpine-base AS run

# Inspired by https://github.com/vlang/docker/blob/master/docker/vlang/Dockerfile.alpine
ENV VFLAGS="-cc gcc"
RUN apk --no-cache add \
    gcc musl-dev git libexecinfo-static libexecinfo-dev libc-dev

RUN apk add --no-cache jq sed

# Copy the prebuilt V compiler
COPY --from=build /opt/vlang /opt/vlang

WORKDIR /tmp/sample
COPY pre-compile/ ./
RUN v -stats test run_test.v

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
