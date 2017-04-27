#! /bin/bash

# Only process first job in matrix (TRAVIS_JOB_NUMBER ends with ".1")
if [[ ! $TRAVIS_JOB_NUMBER =~ \.1$ ]]; then
  echo "Skipping deploy since it's not the first job in matrix"
  exit 0
fi

# Don't process pull requests
# $TRAVIS_PULL_REQUEST will be the PR number or "false" if not a PR
if [[ -n "$TRAVIS_PULL_REQUEST" ]] && [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "Skipping deploy because it's a pull request"
  exit 0
fi

# Only process branches listed in DEPLOY_BRANCHES
BRANCHES_TO_DEPLOY=($DEPLOY_BRANCHES)
if [[ ! " ${BRANCHES_TO_DEPLOY[@]} " =~ " ${TRAVIS_BRANCH} " ]]; then
  # whatever you want to do when arr contains value
  echo "Skipping deploy, not a branch to be deployed"
  exit 0
fi

pip install awscli -q

if [ $? = 0 ]; then
  AWSBIN=$(which aws)
  AWSPATH=$(dirname $AWSBIN)
  export PATH=$PATH:$AWSPATH
  export SCRIPTDIR=$(dirname "$0")

  $SCRIPTDIR/docker_push.sh &&
  $SCRIPTDIR/ecs_deploy.sh

else
  echo "Failed to install AWS CLI"
  exit 1
fi