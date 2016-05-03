#!/bin/sh

YELLOW='\033[0;33m'
GRAY='\033[0;37m'
GREEN='\033[1;32m'
RED='\033[1;31m'

for line in */; do
  cd $line
  echo "${YELLOW}Entering $line${GRAY}"
  gitstatus=$(git status 2>&1)
  error=$(echo $gitstatus | grep -o "fatal:")
  if [ -z "$error" ]; then
    echo "\tFetching..."
    git fetch
    uptodate=$(echo $gitstatus | grep -o "up-to-date")
    if [ "$uptodate" ]; then
      echo "\t${GREEN}$(echo $line | sed 's/\/$//') seems to be up-to date, no need to update${GRAY}"
    fi
    commit=$(echo $gitstatus | grep -o "\(Untracked files\)\|\(Changes to be commited\)")
    if [ "$commit" ]; then
      echo "\t${YELLOW}WARNING:${GRAY} Maybe a commit is pending. The repository will not be updated."
      echo "${YELLOW}\t\"git status\" response:${GRAY}\n$gitstatus"
    fi
    if [ -z "$uptodate" ] && [ -z "$commit" ]; then
      remote=$(echo $gitstatus | grep -o "'.*'" | sed "s/'//g" | cut -d"/" -f1)
      branch=$(echo $gitstatus | grep -o "'.*'" | sed "s/'//g" | cut -d"/" -f2)
      echo "\t${GREEN}Updating...${GRAY}"
      sleep 1
      git pull $remote $branch
    fi
  else
    echo "\t${RED}$(echo $line | sed 's/\/$//') had an error, maybe is not a repository?${GRAY}"
    echo "${YELLOW}\t\"git status\" response:${GRAY}\n$gitstatus"
  fi
  cd ..
done
