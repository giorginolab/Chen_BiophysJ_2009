#!/bin/bash

# Notes for the conversion of Chen-Sherman's model in PharmML. Based
# directly off the original XPP version.

# Location of the http://infix2pharmml.sourceforge.net driver program.
c="perl ./convert.pl -q"


# Convert function definitions, one line at a time
rm functions.xml
while read line
do
  if [[ ! ($line =~ ^#) ]]; then
      $c "$line" >> functions.xml
  fi
done < functions.infix2pharmml


# Gobble the structural model and convert it
$c -s "`cat structural.infix2pharmml`" > structural.xml

# PharmML lacks the delay() function
# measured:=4.5*(SE - delay(SE, tau)) {4.5 is for 9 pg/granule, so this gives pg/cell/min}


# Merge the two
sed '/<!-- Insert FunctionDefinition here -->/ r functions.xml' structural.xml > model.xml


# Final pp
xml_pp -i model.xml

