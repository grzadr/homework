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
sort -t '|' --parallel=8 -k 3 -r | \
awk -F"${DELIMITER}" '
BEGIN {
    delete first["1"]
    delete last["1"]
}
{
    if (NF != 5) {
        print "Error line [" NR "]. Wrong number of fields [" NF "]" >> "/dev/stderr"
        exit 1
    }
    # else {
    #     print $0
    # }
    
    user_id=$4
    match($5, "a=([0-9A-Za-z]+)", matched)

    if (! matched[1]) {
        # print "Line [" NR "] does not contain article id" >> "/dev/stderr"
        # print $0
        next
    }
    article_id=matched[1]

    match($5, "n=([0-9A-Za-z]+)", matched)

    if (! matched[1]) {
        # print "Line [" NR "] does not contain wiki id" >> "/dev/stderr"
        # print $0
        next
    }

    wiki_id=matched[1]

    if (! (user_id in first)){
        first[user_id]=article_id "|" wiki_id
    } else {
        last[user_id]=article_id "|" wiki_id
    }
}
END {
    # print "Analyzed lines: " NR >> "/dev/stderr"
    # print "Registered users: " length(first) >> "/dev/stderr"
    # print "Multiple visits: " length(last) >> "/dev/stderr"
    n=asorti(first, first_sorted)
    print "User id,Is same article,Is same wiki"
    for (i = 1; i <= n; i++){
        user_id=first_sorted[i]
        if (! (user_id in last)){
            continue
        }
        f=split(first[user_id], first_values)
        l=split(last[user_id], last_values)

        article_equal= (first_values[1] == last_values[1]) ? "TRUE" : "FALSE"
        wiki_equal= (first_values[2] == last_values[2]) ? "TRUE" : "FALSE"
        print  user_id "," article_equal "," wiki_equal
    }
}
'
 exit 0