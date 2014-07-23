#!/bin/bash
tag=$1

cat << EOF
{ "version": "$tag" }
EOF
