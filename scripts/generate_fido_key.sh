#!/bin/bash

set -o errexit

ssh-keygen -t ecdsa-sk -f ./id_ecdsa_test -C "Test Key"
