#!/usr/bin/env bash

set -e 

cd ~

echo "Running `basename $0`"

if ! which tar >/dev/null 2>&1
then
    echo "ERROR: tar is not found on the system! This test profile needs tar to extract the source code."
	echo 2 > ~/install-exit-status
fi

tar xfz abs-case-study.tar.gz > /dev/null;

if ! which brew >/dev/null 2>&1
then
    echo "ERROR: brew is not found on the system! This test profile needs brew to install dependencies"
	echo 2 > ~/install-exit-status
fi

if brew info libomp | grep "Not installed"
then
    brew install libomp > /dev/null;
fi

if ! ls $HOMEBREW_REPOSITORY/lib/ | grep libomp
then
    brew link --force libomp > /dev/null;
fi

echo "Dependency check done";

cd abs-case-study-1.0.0;

# check if make exists
make all;

# check if g++ exists
# check if awk, gnuplot exits

bench="";
host=m1pro-test-suite;
if [ `uname -m` == aarch64 ] || [ `uname -m` == arm64 ]
then
    bench=benchArm;
elif [ `uname -m` == i386 ] || [ `uname -m` == x86_64 ]
then
    bench=bench;
fi

cd ~
echo "#!/usr/bin/env bash

cd abs-case-study-1.0.0;
./scripts/${bench}.sh ${host};
echo \$? > ~/test-exit-status;
cat stat/${host}/abs-result.txt > \$LOG_FILE

" > abs-case-study
chmod +x abs-case-study

echo 0 > ~/install-exit-status
