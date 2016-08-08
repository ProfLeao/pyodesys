#!/bin/bash -xeu
PKG_NAME=${1:-${CI_REPO##*/}}
if [[ "$CI_BRANCH" =~ ^v[0-9]+.[0-9]?* ]]; then
    eval export ${PKG_NAME^^}_RELEASE_VERSION=\$CI_BRANCH
    echo ${CI_BRANCH} | tail -c +2 > __conda_version__.txt
fi
python2.7 setup.py sdist
for PYTHON in python2.7 python3.4; do
    (cd dist/; $PYTHON -m pip install $1-$($PYTHON ../setup.py --version).tar.gz)
    (cd /; $PYTHON -m pytest --pyargs $1)
    $PYTHON -m pip install --user -e .[all]
    $PYTHON -m pip install --user symcxx pysym
done
PYTHONPATH=$(pwd) PYTHON=python2.7 ./scripts/run_tests.sh
PYTHONPATH=$(pwd) PYTHON=python3.4 ./scripts/run_tests.sh --cov $1 --cov-report html
! grep "DO-NOT-MERGE!" -R . --exclude ci.sh
