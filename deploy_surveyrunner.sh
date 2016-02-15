#!/bin/bash
#
# Assumes
# Call this script with the AWS elasticbeanstalk app name and env name

SURVEYRUNNER_REPO_URL=https://github.com/ONSdigital/eq-survey-runner
BRANCH=master
pip install --user awsebcli

echo $SURVEYRUNNER_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $SURVEYRUNNER_REPO_URL
cd ./eq-survey-runner
for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; do
   git branch --track ${branch#remotes/origin/} $branch
done
git checkout $BRANCH
git pull

VERSION=`python --version`
echo "*****************************************************"
echo "Using Python version: ${VERSION}"
echo "*****************************************************"


# We can't seem to pass in that we DON'T want SSH keys. Urgh.
eb init -i -r eu-west-1 -p "Python 3.4" $1 <<<n
npm install && npm run compile
# While we await Vault implemetation for KEYMAT handling.
# We place JWT behind a feature flag
eb setenv EQ_PRODUCTION=false
eb deploy $2
