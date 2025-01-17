#! /bin/bash

cd "$(dirname "$(readlink -f "$0")")" && cd ../../certificates || {
  echo "Unable to go to certificates folder" >&2
  exit 1
}

bundle='ca-bundle.crt'

# If cacert.pem does not exist or is older than 666 days, download it
age="$(($(date +%s) - $(date -r "cacert.pem" +%s 2>/dev/null || echo $(($(date +%s) + 1)))))"
if [[ -n "$age" && "$age" -gt 0 && "$age" -ge 57542400 ]] || [ ! -f cacert.pem ]; then
  echo "Downloading the certificates bundle from https://curl.se/ca/cacert.pem..."
  if ! curl -sSLo ./cacert.pem https://curl.se/ca/cacert.pem; then
    echo "Unable to download the certificates bundle from https://curl.se/ca/cacert.pem" >&2
    echo "Please download it and save it in $(cygpath -w "$(pwd)")/cacert.pem" >&2
    rm -f ./cacert.pem
    exit 1
  fi
  rm "$bundle"
fi

[ -f "$bundle" ] && exit 0

echo "Generating ${bundle}..."

{
  cat ./cacert.pem
  while read -r entry; do
    if [ -f "$entry" ]; then
      printf '\n%s\n=====================================\n' "$(basename -s .crt "$entry")"
      cat "$entry"
    else
      while read -r cert; do
        printf '\n%s\n=====================================\n' "$(echo "$cert" | cut -b 3- | tr '/' ':' | xargs basename -s .crt)"
        cat "$cert"
      done < <(find "$entry" -type f -name '*.crt')
    fi
  done < <(find . -mindepth 1 -maxdepth 1 -type d -o -type f -name "*.crt" ! -name ca-bundle.crt)
} >>"$bundle"
