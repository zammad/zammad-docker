#!/bin/bash

set -ex

GITHUB_DEST=$1

git checkout $CI_BUILD_REF_NAME
if [ "$CI_BUILD_REF_NAME" != "$CI_BUILD_TAG" ]; then
  git pull --rebase origin $CI_BUILD_REF_NAME
fi

if git remote | grep github > /dev/null; then
  git remote rm github
fi
git remote add github $GITHUB_DEST

if [ "$CI_BUILD_REF_NAME" != "$CI_BUILD_TAG" ]; then
  git push github $CI_BUILD_REF_NAME
else
  git push github --tags
fi
