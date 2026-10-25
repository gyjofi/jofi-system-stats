#!/usr/bin/env bash

set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
metadata_file="${project_root}/metadata.json"
output_dir="${project_root}/dist"

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required to read the package version." >&2
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    echo "Error: zip is required to create the Plasma package." >&2
    exit 1
fi

version="$(jq -r '.KPlugin.Version' "${metadata_file}")"

if [[ -z "${version}" || "${version}" == "null" ]]; then
    echo "Error: no KPlugin.Version found in metadata.json." >&2
    exit 1
fi

package_name="jofi-system-stats-${version}.plasmoid"
staging_dir="$(mktemp -d)"
trap 'rm -rf "${staging_dir}"' EXIT

mkdir -p "${output_dir}"
rm -f "${output_dir}"/*.plasmoid

cp "${metadata_file}" "${staging_dir}/metadata.json"
cp -R "${project_root}/contents" "${staging_dir}/contents"

(cd "${staging_dir}" && zip -qr "${output_dir}/${package_name}" metadata.json contents)

echo "Created ${output_dir}/${package_name}"
