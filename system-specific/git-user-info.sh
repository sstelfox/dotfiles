#!/bin/bash

# Setting these variables prevents the need to set them in the
# gitconfig file which is useful because the gitconfig file can't
# source other files, and these can be system specific between say
# work and home machines.
export GIT_COMMITTER_EMAIL="didnt_change@thedefaults.here"
export GIT_COMMITTER_NAME="Some Guy"

# You probably don't need to change these unless they're different
# for some reason than those above
export GIT_AUTHOR_EMAIL=$GIT_COMMITTER_EMAIL
export GIT_AUTHOR_NAME=$GIT_COMMITTER_NAME
