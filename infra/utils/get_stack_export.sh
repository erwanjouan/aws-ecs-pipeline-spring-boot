#!/bin/sh

QUERY_FILTER="Stacks[0].Outputs[?OutputKey=='${2}'].OutputValue"

aws cloudformation describe-stacks \
  --stack-name "$1" \
  --query "${QUERY_FILTER}" \
  --output text
