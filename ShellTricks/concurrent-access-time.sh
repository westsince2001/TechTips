#!/bin/bash
for ((i=0;i<=4;i++))
do
{
#echo $i
#sleep 1
#echo 1 >>a.txt && echo "done!"
echo "process" $i
curl -vo /dev/null -H "Host:w.gdown.baidu.com" "http://117.139.23.47/data/wisegame/11c4607d161b72dd/wodeshijie_1343.apk?f=m1101"
} &
done


export TIMEFORMAT="%E"
for ((i=0;i<=15;i++))
do
 {
echo "process" $i
 elapsed=`(time curl -so /dev/null -H "Host:w.gdown.baidu.com" "http://117.139.23.47/data/wisegame/11c4607d161b72dd/wodeshijie_1343.apk?f=m1101") 2>&1`
echo "process" $i over 
 echo "process ${i} spent: ${elapsed} seconds" >> b.txt 
} &


