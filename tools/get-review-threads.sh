#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <owner> <repo> <pull_number>" >&2
  exit 1
fi

owner="$1"
repo="$2"
pr="$3"

gh api graphql -f query='
query($owner:String!, $repo:String!, $pr:Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 100) {
            nodes {
              id
              author { login }
              path
              body
              createdAt
            }
          }
        }
      }
    }
  }
}' -F owner="$owner" -F repo="$repo" -F pr="$pr" \
  --jq '.data.repository.pullRequest.reviewThreads.nodes
        | map(select(.isResolved == false))'
