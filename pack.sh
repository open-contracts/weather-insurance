#!/bin/sh
# TODO: Enforce pip3 version to ensure that what is downloaded from pypi is reproducible
mkdir packages/
pip3 download --destination-directory packages -r requirements.txt
tar -cvf packages.tar packages/
# create pack.tar or something
