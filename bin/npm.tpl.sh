#!/bin/bash
versions="$1"

cat << EOF
{ "versions": ["$versions"] }
EOF
