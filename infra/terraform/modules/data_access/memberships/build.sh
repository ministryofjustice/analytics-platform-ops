#! /usr/bin/env bash
set -ex

cd $(dirname $0)
pip3 install -r requirements.txt --upgrade -t .
# Local/common packages
pip3 install ../common/naming --upgrade -t .
pip3 install ../common/sentry --upgrade -t .
