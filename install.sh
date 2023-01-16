#!/usr/bin/env bash

set -e

cd ~

echo "Running `basename $0`"

# check if tar exists
tar xfz abs-case-study.tar.gz;

# check if apt-get exists
apt-get install -y libomp-dev > /dev/null;

echo "Dependency check done";

cd abs-case-study-1.0.0;

# check if make exists
make all;

# check if g++ exists
# check if awk, gnuplot exits

script="";
host=test-host;
if [ `uname -m` == aarch64 ] || [ `uname -m` == arm64 ]
then
    script=bench_time_arm;
elif [ `uname -m` == i386 ] || [ `uname -m` == x86_64 ]
then
    script=bench_time_x86_64;
fi

cd ~
echo "#!/usr/bin/env bash

cd abs-case-study-1.0.0;
./scripts/${script}.sh ${host};
cat stats/${host}/abs-result.txt > \$LOG_FILE
echo \$? > ~/test-exit-status;

" > abs-case-study
chmod +x abs-case-study
