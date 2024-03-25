set -e
curl -sLo "$5" "$(gh api graphql \
  -f owner="$2" -f name="$3" -f tag="$4" \
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
mkdir -p "extracts/addons/$1"
unzip -q -o -d "extracts/addons/$1" "$5"
