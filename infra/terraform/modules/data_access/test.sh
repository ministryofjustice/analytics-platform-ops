#! /usr/bin/env bash
set -ex

echo "Setting test environment..."
BASE_DIR=$(cd $(dirname $0) ; pwd -P)
cd $BASE_DIR
python3 -mvenv venv
source venv/bin/activate
pip3 install -r requirements.dev.txt
deactivate
source venv/bin/activate
# Required by boto in CI
export AWS_DEFAULT_REGION=eu-west-1

echo "Running tests..."
for tests_dir in "membership_events" "memberships" "organization_events" "team_events" "teams" "users";
do
  cd "$BASE_DIR/$tests_dir"
  pytest ./tests --spec
done
