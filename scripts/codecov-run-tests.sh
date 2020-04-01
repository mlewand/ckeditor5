#!/bin/bash

# @license Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

changedPackages=$(git diff master --stat | head -n-1  | awk '{$1=$1};1' | sed -e '/^packages\//!s/.*/ckeditor5/' -e 's#^\s*packages\/ckeditor5\?-\([^\/]\+\).\+#\1#' | sort -u)
csvChangedPackages=$(echo $changedPackages | sed -e 's/ /,/g')

echo $changedPackages
echo $csvChangedPackages

`yarn run test -f $csvChangedPackages --reporter=dots --production --coverage`

for package in $changedPackages; do
  `codecov -F $package`
done
