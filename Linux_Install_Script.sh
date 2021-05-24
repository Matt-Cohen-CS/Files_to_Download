#!/bin/bash

# This script will be used to install all Linux packages that will be needed in a fresh install

# Resources: 
#
#
echo "Please type your email address"
read name
ssh-keygen -t ed25519 -C "$name"
eval "$(ssh-agent -s)"
