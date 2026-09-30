# Exercism V Test Runner

The Docker image to automatically run tests on V solutions submitted to [Exercism].

## Contributing

We 💙 our community, but **this repository does not accept unsolicited pull requests at this time**.

Please read this [community blog post][guidelines] for details.

## Run the test runner

To run the tests of an arbitrary exercise, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run.sh <exercise-slug> <solution-dir> <output-dir>`

Once the test runner has finished, its results will be written to `<output-dir>/results.json`.

## Run the test runner on an exercise using Docker

_This script is provided for testing purposes, as it mimics how test runners run in Exercism's production environment._

To run the tests of an arbitrary exercise using the Docker image, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-in-docker.sh <exercise-slug> <solution-dir> <output-dir>`

Once the test runner has finished, its results will be written to `<output-dir>/results.json`.

## Run the tests

To run the tests to verify the behavior of the test runner, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-tests.sh`

These are [golden tests][golden]. Each test is a directory under `tests/` holding an exercise for the runner to run, plus an `expected_results.json` holding the results that run is expected to produce. `bin/run-tests.sh` runs the test runner over every directory in `tests/`, normalises the `results.json` it writes alongside — stripping elapsed times, line and byte counts, and the build's temporary session path, so the output is stable between runs — and then diffs it against `expected_results.json`.

When a change alters the expected output, regenerate the golden file: run the tests, then copy `tests/<test-name>/results.json` over `tests/<test-name>/expected_results.json` and commit that. The generated `results.json` is ignored by git; `expected_results.json` is the file that is tracked.

The expected results embed V's own output, including its compiler diagnostics and the test names it prints, so they are tied to the V release the image pins. Bumping `release_tag` in the `Dockerfile` means re-running the tests and regenerating the `expected_results.json` that change.

## Run the tests using Docker

_This script is provided for testing purposes, as it mimics how test runners run in Exercism's production environment._

To run the tests to verify the behavior of the test runner using the Docker image, do the following:

1. Open a terminal in the project's root
2. Run `./bin/run-tests-in-docker.sh`

This runs the same tests, against the same `expected_results.json` files, but through the Docker image that mirrors the production environment. This is what CI runs.

[golden]: https://ro-che.info/articles/2017-12-04-golden-tests
[exercism]: https://exercism.io
