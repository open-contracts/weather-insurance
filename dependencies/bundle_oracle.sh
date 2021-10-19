#!/bin/sh
# TODO: Enforce pip3 version to ensure that what is downloaded from pypi is reproducible
mkdir -p oracle_bundle/pip
pip3 install wheel eth-utils
pip3 wheel --wheel-dir oracle_bundle/pip -r requirements.txt
cp ../oracle.py oracle_bundle/
cp domain_whitelist.txt oracle_bundle/
zip -r oracle_bundle.zip oracle_bundle/
rm -rf ./oracle_bundle
echo "Oracle Hash:" $(sha256sum oracle_bundle.zip | awk '{print $1}')
