#!/bin/sh


ab -v 3 -q -n 10000 -c 100 -H "X-Forwarded-For: 127.0.0.1" http://localhost:3000/ | grep -iE "ok|\(429\)" | sort | uniq -c
