#!/bin/sh
set -e

rm -f /opt/etcd-${version_etc}-linux-amd64.tar.gz

rm -rf /opt/etcd && mkdir -p /opt/etcd

curl -L https://storage.googleapis.com/etcd/${version_etc}/etcd-${version_etc}-linux-amd64.tar.gz -o /opt/etcd-${version_etc}-linux-amd64.tar.gz

tar xzvf /opt/etcd-${version_etc}-linux-amd64.tar.gz -C /opt/etcd --strip-components=1

