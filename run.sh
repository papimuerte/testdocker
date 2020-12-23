#!/bin/sh
set -e
# mount s3, getting creds from environment
echo "$AWS_ACCESS_KEY_ID:$AWS_SECRET_ACCESS_KEY" > passwd && chmod 600 passwd
mkdir /s3
s3fs leela-videos /s3 -o passwd_file=passwd -o host=https://nyc3.digitaloceanspaces.com
# start daikon
/usr/bin/python3  pyleela/brain/WAMPAgent.py

