FROM thevlang/vlang:alpine-build AS build
# The vlang "-dev" images currently contain a version of V that is both well behind the
# mainstream version of V, and cannot be pinned to a known version. So instead we use
# their "-build" image to get the dependencies we need, and build the version of V we want.
# This trades a longer build for a more deterministic and maintainable one.
# Ref: https://github.com/exercism/vlang-test-runner/issues/10

# Specify the version of V to build. The defaults give the recent known-good "V 0.3.3 b71c131"
# from https://github.com/vlang/v/tree/b71c131678c56adaf3feb0cff896176326cdd043
ARG v_branch=master
ARG v_hash=b71c131678c56adaf3feb0cff896176326cdd043

# Use the same method to build V as in:
# https://github.com/vlang/docker/blob/master/docker/vlang/Dockerfile.alpine
# Note: The combination of Alpine, emulation and tcc seem to make this an inefficient method.
#       Given V is typically fast to build, there may be improvements available here.
WORKDIR /opt/vlang
RUN git clone --branch ${v_branch} https://github.com/vlang/v /opt/vlang && \
	git checkout ${v_hash} && \
	make VFLAGS='-cc gcc' && \
	v -version


FROM thevlang/vlang:alpine-base AS run

# Run time pre-reqs, derived from https://github.com/vlang/docker/blob/master/docker/vlang/Dockerfile.alpine
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
