#!/bin/bash
set -ev
if [ "${TRAVIS_BRANCH}" = "master" ]; then
  eval "$(ssh-agent -s)"
  chmod 600 .travis/deploy_key.pem
  ssh-add .travis/deploy_key.pem

  git clone -b gh-pages --single-branch $PAGES_REPO_URI pages
  git config --global user.email "travis@splashes"
  git config --global user.name "Travis Build Bot"

  cd pages
  cp -v ../game.js $DEST_FILE

  git add $DEST_FILE
  git commit -m "Update to ${TRAVIS_COMMIT}"

  git push
fi
