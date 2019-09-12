#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"



c=$DIR/convert.pl

if [[ $# -ne 2 ]]; then
    cat <<EOF
Use infix2pharmml to convert a given structural model (in standalone mode),
then merge-in function definitions, converted one per line in single-statement mode.

Usage: $0 <structural.infix> <functions.infix> > model.pharmml
 - <structural.infix>     should contain the structural equations
 - <functions.infix>      should contain the function definitions

EOF
    exit
fi

tmp=`mktemp`
mod=$1
fun=$2


# Convert function definitions, one line at a time
while read line
do
  if [[ ! ($line =~ ^#) ]]; then
      perl $c "$line" >> $tmp
  fi
done < $fun


# Gobble the structural model and convert it, merging functions
perl $c -s < $mod | \
    sed "/<!-- Insert FunctionDefinition here -->/ r $tmp" 

rm $tmp
