#!/bin/bash

if [ ! -d output ]
then
  echo "Creating output directory."
  mkdir output
fi

if [ ! -d plots ]
then
  echo "Creating plots directory."
  mkdir plots
fi

# This is the end of the file.
