#!/bin/bash
#-----------------------------------------------------------------------
#
# PURPOSE: synchronize a remote fork (default: origin) with an upstream
#          repository (default: upstream).
#
# NOTEs:
#    1. Must be run from a working copy of a repo.
#    2. The working copy must have two remotes, one for the "origin" and the
#       other for the "upstream" (remote names can be others).
#    3. ENTER for each input to use the default value.
#
# Author: Yunheng Wang (06/26/2020)
#
# History:
#    Initial code on 06/26/2020.
#
#-----------------------------------------------------------------------

remotes=($(git remote))
if [[ $? -ne 0 ]]; then
  exit 0
fi

#
# Get upstream & origin
#
remotestr=$(IFS=,  ; echo "${remotes[*]}")

if [[ ${#remotes[@]} -lt 2 ]]; then
  echo "No enough remotes to update, remotes are: [${remotestr}]"
  echo "To add an upstream: $> git remote add upstream URL"
  echo ""
  exit 0
else
  #
  # find default index for upstream & origin in ${remotes[*]}
  #
  indx_origin=0
  indx_upstream=1

  for i in "${!remotes[@]}"; do
     if [[ "${remotes[$i]}" == "origin" ]]; then
         indx_origin=$i
     fi
     if [[ "${remotes[$i]}" == "upstream" ]]; then
         indx_upstream=$i
     fi
  done

  #
  # Read user choice
  #
  read -p "Which remote is the upstream [${remotestr}] (default: ${remotes[$indx_upstream]}): " upstream
  if [[ "$upstream" == "" ]]; then
    upstream=${remotes[$indx_upstream]}
  fi

  read -p "Which remote is the origin   [${remotestr}] (default: ${remotes[$indx_origin]})  : " origin
  if [[ "$origin" == "" ]]; then
    origin=${remotes[$indx_origin]}
  fi

fi

#
# Get branch
#
branches=($(git branch --column --format='%(refname:short)'))
branchestr=$(IFS=,  ; echo "${branches[*]}")

read -p "Which branch to be updated   [${branchestr}] (default: ${branches[0]})  : " branch
if [[ "$branch" == "" ]]; then
  branch=${branches[0]}
fi

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

echo ""
echo "Update $branch from $upstream to $origin ...."
echo ""

# 1. checkout out branch
git checkout $branch
if [[ $? -ne 0 ]]; then
  echo ""
  echo "Checkout branch: $branch failed."
  exit $?
fi

#2. Pull updates from upstream
git pull $upstream $branch
if [[ $? -ne 0 ]]; then
  echo ""
  echo "Pull from upstream: $upstream failed."
  exit $?
fi

#3. Push change to fork
git push $origin
if [[ $? -ne 0 ]]; then
  echo ""
  echo "Push to origin: $origin failed."
  exit $?
fi

exit 0

