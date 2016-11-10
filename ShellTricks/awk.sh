#! /bin/bash

for i in `docker images | grep testtimestamp | awk 'BEGIN{OFS=":";}{print $1 OFS $2}'`; do docker push $i; done
