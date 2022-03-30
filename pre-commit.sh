#!/bin/sh
find src/ -type f -name '*.py' ! -path "*/migrations/*" | xargs reorder-python-imports
find src/ -type f -name '*.py' ! -path "*/migrations/*" | xargs add-trailing-comma
black src
cd src/
flake8 --max-line-length=88 --ignore=E203,W503