#!/bin/sh
unzip oracle_bundle.zip
pip3 install --no-index --find-links=oracle_bundle/pip -r requirements.txt
