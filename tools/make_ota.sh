#!/bin/bash
#
# Copyright (C) 2025 Venkata Atchuta Bheemeswara Sarma Darbha
#
# SPDX-License-Identifier: Apache-2.0
#
# Generate the OTA package for opi5_pro from the artifacts of `m dist`.
#
# `m dist` produces the target_files and otatools zips but not the OTA zip, and
# this board's target_files lack META/ab_partitions.txt and
# META/dynamic_partitions_info.txt (A/B config inherited, but no super
# partition), which makes ota_from_target_files fail. This script adds those
# files to a temporary copy of the target_files and runs the tool. The original
# target_files are not modified.
#
# Usage (from the Android source root, after `m dist DIST_DIR=out/dist`):
#   device/opi/opi5_pro/tools/make_ota.sh [DIST_DIR] [OUTPUT_ZIP]
#
set -euo pipefail

DIST_DIR="${1:-out/dist}"
OUTPUT="${2:-${DIST_DIR}/aosp_opi5_pro-ota.zip}"
AB_PARTITIONS=(boot system vendor)

TARGET_FILES="${DIST_DIR}/aosp_opi5_pro-target_files-android.zip"
OTATOOLS="${DIST_DIR}/otatools.zip"

for f in "${TARGET_FILES}" "${OTATOOLS}"; do
  [[ -f "$f" ]] || { echo "error: $f not found (run 'm dist DIST_DIR=${DIST_DIR}' first)" >&2; exit 1; }
done
command -v zip >/dev/null || { echo "error: 'zip' is required" >&2; exit 1; }
command -v unzip >/dev/null || { echo "error: 'unzip' is required" >&2; exit 1; }

WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"' EXIT

echo ">> Extracting otatools"
mkdir -p "${WORK}/otatools"
unzip -q "${OTATOOLS}" -d "${WORK}/otatools"

echo ">> Preparing target_files"
cp "${TARGET_FILES}" "${WORK}/target_files.zip"
mkdir -p "${WORK}/stage/META"
(
  cd "${WORK}/stage"
  has() { unzip -l ../target_files.zip "$1" >/dev/null 2>&1; }

  if ! has META/ab_partitions.txt; then
    printf '%s\n' "${AB_PARTITIONS[@]}" > META/ab_partitions.txt
    zip -q ../target_files.zip META/ab_partitions.txt
    echo "   added META/ab_partitions.txt"
  fi
  if ! has META/dynamic_partitions_info.txt; then
    # Empty stub: no super partition / dynamic partition groups.
    printf 'super_partition_groups=\n' > META/dynamic_partitions_info.txt
    zip -q ../target_files.zip META/dynamic_partitions_info.txt
    echo "   added META/dynamic_partitions_info.txt"
  fi
)

echo ">> Generating OTA -> ${OUTPUT}"
"${WORK}/otatools/bin/ota_from_target_files" "${WORK}/target_files.zip" "${OUTPUT}"

echo ">> Done: ${OUTPUT}"
