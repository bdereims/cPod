#!/bin/bash

ADJECTIVES=( "tall" "small" "tiny" )
NAMES=( "dog" "horse" "cat" )

while : ; do
	R1=$( echo $RANDOM % 10 | bc )
	[ -z ${ADJECTIVES[${R1}]} ] || break
done

while : ; do
	R2=$( echo $RANDOM % 10 | bc )
	[ -z ${NAMES[${R2}]} ] || break
done

echo "${ADJECTIVES[${R1}]}-${NAMES[${R2}]}"
