#!/bin/bash

set -eu
set -o pipefail

DELIMITER='|'
FILENAME='-'

if [[ $# == 1 ]]; then
    if [[ ! -r "${1}" ]]; then
        echo "File ${1} does not exist!" >&2
        exit 1
    fi

    FILENAME="${1}"
    
elif [[ $# > 1 ]]; then
    echo "Too many arguments!" >&2
    exit 1
fi

cat $FILENAME | \
sort -t '|' -k 4,4 -k 3,3 --stable | \
awk -F"${DELIMITER}" '
BEGIN {
    delete first["1"]
    delete last["1"]
    delete ordered["1"]
    delete first_recorded["1"]
    delete last_recorded["1"]
    missing=0
    counter=0
}
{
    if (NF != 5) {
        print "Error line [" NR "]. Wrong number of fields [" NF "]" >> "/dev/stderr"
        exit 1
    }
    timestamp=$3
    user_id=$4
    result = match($5, "[?&]a=([-%0-9A-Za-z]+)", matched)
    if (result == 0) {
        missing++
        # print "Line [" NR "] does not contain article id" >> "/dev/stderr"
        next
    }
    article_id=matched[1]

    result = match($5, "[?&]n=([-%0-9A-Za-z]+)", matched)
    if (result == 0) {
        missing++
        # print "Line [" NR "] does not contain wiki id" >> "/dev/stderr"
        next
    }
    wiki_id=matched[1]

    if (! (user_id in first)){
        counter++
        ordered[counter]=user_id
        first[user_id]=article_id "|" wiki_id
        first_recorded[user_id]=timestamp
    } else {
        if (first_recorded[user_id] == timestamp){
            next
        }
        
        if (last_recorded[user_id] == timestamp){
            next
        }

        last[user_id]=article_id "|" wiki_id
        last_recorded[user_id]=timestamp
    }

    
}
END {
    print "Analyzed lines: " NR >> "/dev/stderr"
    print "Registered users: " length(first) >> "/dev/stderr"
    print "Missing fields: " length(first) >> "/dev/stderr"
    print "Multiple visits: " length(last) >> "/dev/stderr"
    print "User id,Is same article,Is same wiki"
    # n=asorti(first, first_sorted)
    
    for (i in ordered){
        user_id=ordered[i]
        if (! (user_id in last)){
            continue
        }
        f=split(first[user_id], first_values, "|")
        l=split(last[user_id], last_values, "|")

        article_equal= (first_values[1] == last_values[1]) ? "TRUE" : "FALSE"
        wiki_equal= (first_values[2] == last_values[2]) ? "TRUE" : "FALSE"
        print  user_id "," article_equal "," wiki_equal
    }
}
'
 exit 0