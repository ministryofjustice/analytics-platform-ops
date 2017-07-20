#! /usr/bin/env bash
set -ex

cd $(dirname $0)
pip3 install -r requirements.txt --upgrade -t .
