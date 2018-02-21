#!/bin/bash

export PORT=5101

cd ~/www/tasktracker
./bin/task_tracker stop || true
./bin/task_tracker start