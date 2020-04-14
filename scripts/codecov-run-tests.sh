#!/bin/bash

# @license Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

packages=$(ls packages -1 | sed -e 's#^ckeditor5\?-\(.\+\)$#\1#')

# i=0

errorOccured=0

rm -r -f _coverage
mkdir _coverage
rm -r -f .nyc_output
mkdir .nyc_output

failedPackages=""

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

for package in $packages; do
  # i=$((i+1))

  # if ((i > 3)); then
  #   # for testing purpose use limited number of packages
  #   break
  # fi


  echo -e "Running tests for: ${GREEN}$package${NC}"

  yarn run test -f $package --reporter=dots --production --coverage > /dev/null

  mkdir _coverage/$package

  # cp coverage/*/lcov.info coverage/*/coverage-final.json _coverage/$package
  cp coverage/*/coverage-final.json .nyc_output
  # Keep a copy that will be used for merging to make a combined report.
  cp .nyc_output/coverage-final.json _coverage/coverage-$package.json

  npx nyc check-coverage --branches 100 --functions 100 --lines 100 --statements 100

  if [ "$?" -ne "0" ]; then
    echo "💥 $package doesn't have required code coverage 💥"
    failedPackages="$failedPackages $package"
    errorOccured=1
  fi
done;

echo "Creating a combined code coverage report"

# Combined file will be used for full coverage (as if yarn run test -c was run).
# mkdir _coverage/_combined
# npx nyc merge _coverage _coverage/_combined/coverage.json # move the combined straight to nyc directory
npx nyc merge _coverage .nyc_output/coverage-final.json

# You could attempt to check-coverage here too, but since each subpackage had a correct CC there's no point in doing this
# for combined result.

# # HTML output.
# # npx istanbul report --root _coverage/_combined --dir _coverage/_output html
# coverageSummary=$(npx istanbul report --root _coverage/_combined text-summary)
# echo $coverageSummary

# npx istanbul report --root .nyc_output --dir _coverage/_output html

codecov -f .nyc_output/coverage-final.json

if [ "$errorOccured" -eq "1" ]; then
  echo -e "Following packages did not provide required code coverage: ${RED}$package${NC}"
  exit 1 # Will break the CI build
fi
