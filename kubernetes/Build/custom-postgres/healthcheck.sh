#!/bin/bash

if [ ! $PGDATA ]; then
  echo "PGDATA is not set"
  exit -9
fi

pg_isready -U postgres > /dev/null

if [ $LOAD_DATA ]; then
  if [ -f $PGDATA/loaded-$VERSION_NUMBER ] && [ $? -eq 0 ]
  then
    exit 0                          
  else    
    exit 1                          
  fi
else
  if [ $? -eq 0 ]
  then
    exit 0                          
  else    
    exit 1                          
  fi
fi