#!/usr/bin/env bash

set -e

cd ~

echo "Running `basename $0`"

if which tar >/dev/null 2>&1
then
    tar xfz abs-case-study.tar.gz > /dev/null;
else
    echo "ERROR: tar is not found on the system! This test profile needs tar to extract the source code."
	echo 2 > ~/install-exit-status
    exit 2;
fi


if which apt >/dev/null 2>&1
then
    sudo apt-get install -y gcc make libomp-dev awk gnuplot > /dev/null;
elif which yum >/dev/null 2>&1
then
    sudo yum install -y gcc make libomp-dev awk gnuplot > /dev/null;
else
    echo "ERROR: package manger is not found on the system! This test profile needs either apt or yum to install dependencies"
	echo 2 > ~/install-exit-status;
    exit 2;
fi


echo "Dependency check done";

cd abs-case-study-1.0.0;

make all;


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

echo 0 > ~/install-exit-status