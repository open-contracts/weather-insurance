#!/bin/sh
# TODO: Enforce pip3 version to ensure that what is downloaded from pypi is reproducible
mkdir -p oracle_package/pip
pip3 install wheel
pip3 wheel --wheel-dir oracle_package/pip -r requirements.txt
cp ../oracle.py oracle_package/
cp domain_whitelist.txt oracle_package/
zip -r oracle_package.zip oracle_package/
rm -rf ./oracle_package
