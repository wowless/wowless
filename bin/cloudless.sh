#!/bin/sh
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  "https://wowless-pxnmni7wma-uc.a.run.app/wowless?product=$1&addon=$2" | \
xargs gsutil cat
