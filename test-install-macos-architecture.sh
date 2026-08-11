#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
installer="$repo_dir/install-macos.sh"
real_path="$PATH"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

run_case() {
  local name="$1" kernel="$2" machine="$3" translated="$4" arm64_capable="$5" expected="$6"
  local mock_dir="$work/$name" result
  mkdir -p "$mock_dir"

  cat > "$mock_dir/uname" <<EOF
#!/usr/bin/env bash
[[ "\${1:-}" == "-s" ]] && { printf '%s\n' '$kernel'; exit 0; }
[[ "\${1:-}" == "-m" ]] && { printf '%s\n' '$machine'; exit 0; }
exit 2
EOF
  cat > "$mock_dir/sysctl" <<EOF
#!/usr/bin/env bash
[[ "\${*: -1}" == "sysctl.proc_translated" && '$translated' != absent ]] && { printf '%s\n' '$translated'; exit 0; }
[[ "\${*: -1}" == "hw.optional.arm64" && '$arm64_capable' != absent ]] && { printf '%s\n' '$arm64_capable'; exit 0; }
exit 1
EOF
  chmod +x "$mock_dir/uname" "$mock_dir/sysctl"

  set +e
  PATH="$mock_dir:$real_path" CHOWDER_ARCH_CHECK_ONLY=1 bash "$installer" >"$work/$name.out" 2>"$work/$name.err"
  result=$?
  set -e

  [[ "$result" == "$expected" ]] || {
    printf 'FAIL %s: expected %s, got %s\n' "$name" "$expected" "$result" >&2
    cat "$work/$name.err" >&2
    return 1
  }
  printf 'PASS %s\n' "$name"
}

run_case native-arm64 Darwin arm64 absent absent 0
run_case rosetta-on-arm64 Darwin x86_64 1 absent 0
run_case intel-mac Darwin x86_64 absent 0 1
run_case non-darwin Linux x86_64 absent 0 1
