# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2026 The Linux Foundation

# shellcheck shell=sh
# Sourced library (no shebang): shared URL trust helpers for action
# steps that compare workspace-derived URLs against the
# caller-configured sonar_host_url trust anchor. Keep all URL parsing
# here: duplicated security-sensitive parsing drifts over time and
# reintroduces trust-boundary bugs.
#
# POSIX-compatible (no Bash 4+ features): GitHub macOS runners still
# ship Bash 3.2 as /bin/bash.

# Print the lowercase host[:port] portion of a URL.
# Truncate at the end of the authority (first /, ? or #) before
# stripping userinfo, so https://evil.example?x@real.host cannot
# spoof the host comparison (curl ends the authority at ? too).
# Hostnames are case-insensitive (RFC 4343); normalise for comparison.
url_host() {
  _url_trust_h="${1#*://}"
  _url_trust_h="${_url_trust_h%%/*}"
  _url_trust_h="${_url_trust_h%%\?*}"
  _url_trust_h="${_url_trust_h%%#*}"
  _url_trust_h="${_url_trust_h##*@}"
  printf '%s' "$_url_trust_h" | tr '[:upper:]' '[:lower:]'
}

# Print the lowercase scheme://host[:port] origin of a URL, or nothing
# when the value has no scheme. Comparing full origins (rather than
# enforcing HTTPS and comparing hosts) keeps http:// self-hosted
# SonarQube configurations working: a URL is trusted when its scheme
# and host both match the sonar_host_url trust anchor.
url_origin() {
  case "$1" in
    *://*) ;;
    *) return 0 ;;
  esac
  # A scheme with an empty host (e.g. 'https://'), or an empty scheme
  # (e.g. '://host'), is not a usable origin; print nothing so callers
  # treat it like a scheme-less value
  _url_trust_o=$(url_host "$1")
  _url_trust_s="${1%%://*}"
  if [ -z "$_url_trust_o" ] || [ -z "$_url_trust_s" ]; then
    return 0
  fi
  _url_trust_s=$(printf '%s' "$_url_trust_s" | tr '[:upper:]' '[:lower:]')
  printf '%s://%s' "$_url_trust_s" "$_url_trust_o"
}
