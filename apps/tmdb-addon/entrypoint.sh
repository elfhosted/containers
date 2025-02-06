#!/bin/bash

exec -c 'cd backend && source /venv/bin/activate && exec python /iceberg/backend/main.py & ORIGIN=$ORIGIN node /iceberg/frontend/build'