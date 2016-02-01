#!/bin/bash
#
# Assumes
# Call this script with the AWS elasticbeanstalk app name and env name

AUTHOR_REPO_URL=https://github.com/ONSdigital/eq-author
BRANCH=master
pip install --user ebcli==3.7.2

echo $AUTHOR_REPO_URL
mkdir -p tmp
cd ./tmp
git clone $AUTHOR_REPO_URL
cd ./eq-author
for branch in `git branch -a | grep remotes | grep -v HEAD | grep -v master `; do
   git branch --track ${branch#remotes/origin/} $branch
done
git checkout $BRANCH
git pull

# We can't seem to pass in that we DON'T want SSH keys. Urgh.
eb init -i -r eu-west-1 -p "Python 3.4" $1 <<<n
npm install && npm run compile
eb deploy $2
