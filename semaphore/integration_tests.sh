#!/bin/bash

python -m pip install pip pipenv
python -m pipenv sync
python -m pipenv run python -m semaphore.integration_tests