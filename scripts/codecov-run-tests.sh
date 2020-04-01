#!/bin/bash

# @license Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

# master needs to be explicitly fetched to make a diff https://travis-ci.community/t/setting-an-environment-variable-with-git-diff-master-fails/6018/9
# in case travis is running the script on non-master branch
git fetch --depth=50 origin refs/heads/master:refs/heads/master

changedPackages=$(git diff master --stat | head -n-1  | awk '{$1=$1};1' | sed -e '/^packages\//!s/.*/ckeditor5/' -e 's#^\s*packages\/ckeditor5\?-\([^\/]\+\).\+#\1#' | sort -u)
csvChangedPackages=$(echo $changedPackages | sed -e 's/ /,/g')

echo $changedPackages
echo $csvChangedPackages

yarn run test -f $csvChangedPackages --reporter=dots --production --coverage

for package in $changedPackages; do
  npx codecov -F $package
done
