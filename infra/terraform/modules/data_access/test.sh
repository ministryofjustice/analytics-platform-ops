#! /usr/bin/env bash

echo "Setting test environment..."
cd "$(dirname "$0")"
python3 -mvenv venv
source venv/bin/activate
pip3 install -r requirements.dev.txt
deactivate
source venv/bin/activate

echo "Running tests..."
cd membership_events
pytest ./tests --spec

cd ../memberships
pytest ./tests --spec

cd ../organization_events
pytest ./tests --spec

cd ../team_events
pytest ./tests --spec

cd ../teams
pytest ./tests --spec
