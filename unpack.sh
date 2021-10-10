#!/bin/sh
tar -xvf packages.tar
pip3 install --no-index --find-links=packages -r requirements.txt
rm -rf packages/
~
