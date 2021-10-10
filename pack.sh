#!/bin/sh
# TODO: Enforce pip3 version to ensure that what is downloaded from pypi is reproducible
mkdir packages/
pip3 install wheel
pip3 wheel --wheel-dir packages -r requirements.txt
tar -cvf packages.tar packages/
rm -rf ./packages
# create pack.tar or something
