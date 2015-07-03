#!/bin/bash

# Notes for the conversion of Chen-Sherman's model in PharmML. Based
# directly off the original XPP version.

# Location of the http://infix2pharmml.sourceforge.net driver program.
c="perl ./convert.pl"


# Convert function definitions, one line at a time
echo > functions_tmp.xml
while read line
do
  if [[ ! ($line =~ ^#) ]]; then
      $c "$line" >> functions_tmp.xml
  fi
done < functions.infix2pharmml


# Gobble the structural model and convert it
$c -s "`cat structural.infix2pharmml`" > structural_tmp.xml


# Merge the two
sed '/<!-- Insert FunctionDefinition here -->/ r functions_tmp.xml' structural_tmp.xml > model.xml

# Edit the name
sed -i -e 's|Anonymous - FIXME|Chen_2009_BiophysJ_Exocytosis|' \
    -e 's|Model translated by infix2pharmml.sourceforge.net|Yi-der Chen, Shaokun Wang, and Arthur Sherman, Identifying the Targets of the Amplifying Pathway for Insulin Secretion in Pancreatic &beta;-Cells by Kinetic Modeling of Granule Exocytosis. doi:10.1529/biophysj.107.124990 . Model translated by infix2pharmml.sourceforge.net|' \
    model.xml


# Final pp
xml_pp -i model.xml

