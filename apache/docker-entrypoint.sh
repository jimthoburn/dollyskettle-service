#!/bin/sh

echo "Hello from Docker entrypoint"

# Hand off to the CMD
exec "$@"
s