#!/usr/bin/env sh

# Synopsis:
# Run the Exercism V test runner on a solution.
#
# Arguments:
#   $1: exercise slug
#   $2: path to solution folder
#   $3: path to output directory
#
# Output:
# Writes a v2 results.json to the output directory, per
# https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer path/to/solution/folder/ path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug path/to/solution/folder/ path/to/output/directory/"
    exit 1
fi

slug="$1"
solution_dir=$(realpath "${2%/}")
output_dir=$(realpath "${3%/}")
results_file="${output_dir}/results.json"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

cd "${solution_dir}" > /dev/null

test_output=$(v -stats test run_test.v 2>&1)
exit_code=$?

cd - > /dev/null

# Strip the solution directory prefix from paths so output is portable,
# and remove ANSI color codes (V emits them even when captured)
test_output=$(printf '%s' "${test_output}" | sed -e "s#${solution_dir}/\{0,1\}##g" -e 's/\x1b\[[0-9;]*m//g')

# ---------- Error case (compile failure) ----------
if [ ${exit_code} -ne 0 ] && echo "${test_output}" | grep -q "error:"; then
    jq -n --arg output "${test_output}" \
        '{version: 2, status: "error", message: $output}' > "${results_file}"
    echo "${slug}: done"
    exit 0
fi

# ---------- Extract test_code from the test file (in source order) ----------
# Walks run_test.v line by line. When a "fn test_xxx() {" line is found,
# collects subsequent lines (unindented) as the test body until "}".
test_codes_json=$(jq -Rs '
    split("\n") |
    reduce .[] as $line (
        {inside_test: false, name: "", body: "", result: []};
        if .inside_test then
            if ($line | test("^}")) then
                .result += [{name: .name, test_code: .body}] |
                .inside_test = false | .name = "" | .body = ""
            else
                .body += (if .body != "" then "\n" else "" end)
                       + ($line | ltrimstr("\t"))
            end
        elif ($line | test("^fn test_")) then
            .inside_test = true |
            .name = ($line | capture("fn (?<n>test_[a-zA-Z0-9_]+)") | .n)
        else . end
    ) | .result
' "${solution_dir}/run_test.v")

# ---------- Parse V test output into per-test results ----------
# V prints one "OK" or "FAIL" line per test with the pattern:
#     OK    [1/9]...  | main.test_xxx()
#     FAIL  [1/9]...  | main.test_xxx()
# Lines between results (file:line, assert expression) are accumulated
# as the failure message for the next FAIL.
test_results_json=$(printf '%s' "${test_output}" | jq -Rs '
    def test_name: capture("main\\.(?<n>[^(]+)") | .n;
    split("\n") |
    reduce .[] as $line (
        {pending: "", tests: []};
        if ($line | test("OK.*\\| *main\\.")) then
            .tests += [{
                name: ($line | test_name),
                status: "pass"
            }] | .pending = ""
        elif ($line | test("FAIL.*\\| *main\\.")) then
            .tests += [{
                name: ($line | test_name),
                status: "fail",
                message: .pending
            }] | .pending = ""
        elif ($line | test("^---- Testing|^running tests in:|Summary for|^--------|^Failed command|compilation |generated  |V  source")) then
            .
        else
            .pending += (if .pending != "" then "\n" + $line else $line end)
        end
    ) | .tests
')

# ---------- Merge in source file order ----------
# Use test_codes order (= source file order) as the authority.
# For each test_code entry, find the matching result by name.
tests_json=$(jq -n \
    --argjson codes "${test_codes_json}" \
    --argjson results "${test_results_json}" \
    '[ $codes[] | . as $c |
        ($results[] | select(.name == $c.name)) // {status: "error", message: "Test did not run."}
        | . + $c
    ]')

# ---------- Determine overall status ----------
if [ ${exit_code} -eq 0 ]; then
    overall="pass"
else
    overall="fail"
fi

# ---------- Assemble results and truncate output fields to 500 chars ----------
jq -n --arg status "${overall}" --argjson tests "${tests_json}" '
    def trunc: if length > 500 then .[:481] + " [output truncated]" else . end;
    {version: 2, status: $status, tests: ($tests | map(
        if .output then .output |= trunc else . end
    ))}
' > "${results_file}"

echo "${slug}: done"
