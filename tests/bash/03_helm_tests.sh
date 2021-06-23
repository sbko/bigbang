#!/usr/bin/env bash

# exit on error
set -e

installed_helmreleases=$(helm list -n bigbang -o json | jq '.[].name' | tr -d '"' | grep -v "bigbang")

mkdir -p cypress-tests

for hr in $installed_helmreleases; do
  test_result=$(helm test $hr -n bigbang) && export EXIT_CODE=$? || export EXIT_CODE=$?
  echo "$test_result"
  namespace=$(echo "$test_result" | yq eval '."NAMESPACE"' -)
  test_suite=$(echo "$test_result" | yq eval '.["TEST SUITE"]' -)

  if [ ! $test_suite == "None" ]; then
    mkdir -p cypress-tests/${hr}/tests/cypress
    echo "***** Helm Test Logs for ${hr} *****"
    kubectl logs --tail=-1 -n ${namespace} -l helm-test=enabled
    echo "***** End Helm Test Logs for ${hr} *****"
    if kubectl get configmap -n ${namespace} cypress-screenshots &>/dev/null; then
      kubectl get configmap -n ${namespace} cypress-screenshots -o jsonpath='{.data.cypress-screenshots\.tar\.gz\.b64}' > cypress-screenshots.tar.gz.b64
      cat cypress-screenshots.tar.gz.b64 | base64 -d > cypress-screenshots.tar.gz
      tar -zxf cypress-screenshots.tar.gz --strip-components=2 -C cypress-tests/${hr}/tests/cypress
      rm -rf cypress-screenshots.tar.gz.b64 cypress-screenshots.tar.gz
    fi
    if kubectl get configmap -n ${namespace} cypress-videos &>/dev/null; then
      kubectl get configmap -n ${namespace} cypress-videos -o jsonpath='{.data.cypress-videos\.tar\.gz\.b64}' > cypress-videos.tar.gz.b64
      cat cypress-videos.tar.gz.b64 | base64 -d > cypress-videos.tar.gz
      tar -zxf cypress-videos.tar.gz --strip-components=2 -C cypress-tests/${hr}/tests/cypress
      rm -rf cypress-videos.tar.gz.b64 cypress-videos.tar.gz
    fi
    if [[ ${EXIT_CODE} -ne 0 ]]; then
      exit ${EXIT_CODE}
    fi
  fi
done
