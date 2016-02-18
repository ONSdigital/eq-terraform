#!/bin/bash
#
# Assumes
# ruby -v   Should be 2.2.3
# bundle -v Should be 1.10.6
# gem -v    Should be 2.5.2

SMOKETEST_REPO_URL=https://github.com/ONSdigital/eq-smoke-test.git
BRANCH=master

export EQ_SURVEYRUNNER=$1'-surveys.eq.ons.digital'

mkdir -p tmp
cd ./tmp

git clone $SMOKETEST_REPO_URL

cd ./eq-smoke-test/eq-tests

git checkout $BRANCH
git pull

rbenv global 2.2.3

bundle exec rspec