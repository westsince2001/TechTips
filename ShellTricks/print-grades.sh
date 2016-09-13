#假设源文件为：
#NAME    AGE     SCORE   CLASS
#Tom     12      89      1
#Jerry   13      92      2
#Peter   13      88      2
#Jim     12      88      1
#Sam     13      90      2
#
#输出的格式期望是：
#NAME=Tom, AGE=12, SCORE=89, CLASS=1;
#NAME=Jerry, AGE=13, SCORE=92, CLASS=2;
#NAME=Peter, AGE=13, SCORE=88, CLASS=2;


awk 'NR == 1 { for (i = 1; i <= NF; i++) { fields[i] = $i; } } NR > 1 { for (i = 1; i < NF; i++) { printf("%s=%s\t", fields[i], $i) } printf("%s=%s\n", fields[NF], $NF); }'
