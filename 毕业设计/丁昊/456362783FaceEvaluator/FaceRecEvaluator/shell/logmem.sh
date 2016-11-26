#!/bin/csh -f

while true; do ps aux | grep [5]556 | awk -F'[ ]*' '{ print $6 }' >> $1; sleep 0.1; done
