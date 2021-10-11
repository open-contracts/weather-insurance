#!/bin/sh
unzip oracle_package.zip
pip3 install --no-index --find-links=oracle_package/pip -r requirements.txt
