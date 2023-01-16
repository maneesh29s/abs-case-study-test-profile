#!/usr/bin/env bash

set -e

cd ~

echo "Running `basename $0`"

mkdir -p abs-case-study-source;

if which tar >/dev/null 2>&1
then
    tar xfz abs-case-study.tar.gz --strip-components=1 -C abs-case-study-source/ > /dev/null;
else
    echo "ERROR: tar is not found on the system! This test profile needs tar to extract the source code."
	echo 2 > ~/install-exit-status
    exit 2;
fi

if which brew >/dev/null 2>&1
then
    brew install libomp awk gnuplot > /dev/null;
    brew link --force libomp > /dev/null;
else
    echo "ERROR: brew is not found on the system! This test profile needs brew to install dependencies";
	echo 2 > ~/install-exit-status;
    exit 2;
fi


echo "Dependency check done";

cd abs-case-study-source;

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

cd abs-case-study-source;
./scripts/${script}.sh ${host};
cat stats/${host}/time/abs-result.txt > \$LOG_FILE
echo \$? > ~/test-exit-status;

" > abs-case-study
chmod +x abs-case-study

echo 0 > ~/install-exit-status