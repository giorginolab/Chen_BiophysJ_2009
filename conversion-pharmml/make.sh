#!/bin/bash

# Notes for the conversion of Chen-Sherman's model in PharmML. Based
# directly off the original XPP version.

# Location of the http://infix2pharmml.sourceforge.net driver program.
bash infix2pharmml-code/build.sh structural.infix2pharmml functions.infix2pharmml > model.xml

# Edit name and description
sed -i -e 's|Untitled model|Chen_2009_BiophysJ_Exocytosis|' \
       -e 's|Model translated by infix2pharmml.sourceforge.net|Yi-der Chen, Shaokun Wang, and Arthur Sherman, Identifying the Targets of the Amplifying Pathway for Insulin Secretion in Pancreatic Beta-Cells by Kinetic Modeling of Granule Exocytosis. doi:10.1529/biophysj.107.124990 - Generated by infix2pharmml.sourceforge.net|' \
    model.xml


# Final pp
xml_pp -i model.xml

