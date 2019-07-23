#!/bin/bash

python -m pip install -U pip pipenv
python -m pipenv sync
python -m pipenv run python -m semaphore.integration_tests