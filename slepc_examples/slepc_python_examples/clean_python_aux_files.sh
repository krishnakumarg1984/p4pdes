#!/usr/bin/env bash

find ~ -path '*/__pycache__/*' -delete
find ~ -type d -name '__pycache__' -empty -delete
