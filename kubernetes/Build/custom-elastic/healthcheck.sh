#!/bin/bash

if [ $LOAD_DATA ]; then
  if [ -f /usr/share/elasticsearch/data/loaded-$VERSION_NUMBER ]
  then
    exit 0                          
  else    
    exit 1                          
  fi
fi