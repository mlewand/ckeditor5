#!/bin/bash

# @license Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

packages=$(ls packages -1 | sed -e 's#^ckeditor5\?-\(.\+\)$#\1#')

i=0

for package in $packages; do
  # echo $package
  i=$((i+1))

  if ((i > 1)); then
    # for testing purpose use limited number of packages
    break
  fi

  yarn run test -f $package --reporter=dots --production --coverage
  echo $package
  # npx codecov -F $package
done
