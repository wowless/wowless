set -e
curl -sLo "$4" "$(gh api graphql \
  -f owner="$1" -f name="$2" -f tag="$3" \
  -f query="
query(\$owner: String!, \$name: String!, \$tag: String!) {
  repository(owner: \$owner, name: \$name) {
    release(tagName: \$tag) {
      releaseAssets(first: 100) {
        nodes {
          contentType
          downloadUrl
        }
      }
    }
  }
}
" \
  --jq '.data.repository.release.releaseAssets.nodes[]
  | select(.contentType == "application/zip" or .contentType == "application/x-zip-compressed")
  | .downloadUrl
')"
mkdir -p extracts/addons
unzip -q -o -d extracts/addons "$4"
