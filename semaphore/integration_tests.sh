#!/bin/bash

export PIPENV_VERBOSITY=-1
export PIPENV_CACHE_DIR=$SEMAPHORE_CACHE_DIR

asdf install
/usr/bin/env python3 -m pip install -U pip pipenv
asdf reshim python
/usr/bin/env python3 -m pipenv sync -d
/usr/bin/env python3 -m pipenv run python -m semaphore.integration_tests