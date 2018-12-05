#!/bin/sh

mkdir -p /var/run/secrets/boostport.com
/kubernetes-vault-init
/jq -r '.clientToken' /var/run/secrets/boostport.com/vault-token > /var/run/secrets/vault-token
/vault-template -f /var/run/secrets/vault-token
