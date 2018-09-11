#!/bin/sh

set -e

pcscd -f -x &

echo waiting for pcscd...
sleep 3

exec "$@"
