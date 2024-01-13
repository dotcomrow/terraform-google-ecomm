#!/bin/bash

for file in *.json; do
    mv -- "$file" "${file%.txt}.tf"
done