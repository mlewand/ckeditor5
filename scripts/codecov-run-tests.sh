#!/bin/bash

# @license Copyright (c) 2003-2020, CKSource - Frederico Knabben. All rights reserved.
# For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license

# master needs to be explicitly fetched to make a diff https://travis-ci.community/t/setting-an-environment-variable-with-git-diff-master-fails/6018/9
# in case travis is running the script on non-master branch
git fetch --depth=50 origin refs/heads/master:refs/heads/master

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
  echo "Running full code coverage(TRAVIS_PULL_REQUEST=$TRAVIS_PULL_REQUEST)"
  # Non-pull requests should run check on all packages.
  # It's important to upload results for each package on master, so that pull requests that will follow have a reference code coverage for a given package.
  changedPackages=$(ls packages -1 | sed -e 's#^ckeditor5\?-\(.\+\)$#\1#')
  LF=$'\n'
  changedPackages="${changedPackages}${LF}ckeditor5"
else
  changedPackages=$(git diff master --stat | head -n-1 | awk '{$1=$1};1' | sed -e '/^packages\//!s/.*/ckeditor5/' -e 's#^\s*packages\/ckeditor5\?-\([^\/]\+\).\+#\1#' | sort -u)
fi

csvChangedPackages=$(echo $changedPackages | sed -e 's/ /,/g')

echo "Following packages were detected:"
echo $csvChangedPackages

yarn run test -f $csvChangedPackages --reporter=dots --production --coverage

# Replacing dashes with underscore, as codecov flags needs to match ^[\w\,]+$ regexp.
for package in $(echo $changedPackages | sed -e 's/\-/_/g'); do
  npx codecov -F $package
done
