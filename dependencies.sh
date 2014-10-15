#!/bin/bash
set -e

apt-get update
apt-get install -y puppet build-essential ruby-dev
gem install librarian-puppet --no-rdoc --no-ri
cd /vagrant && librarian-puppet install --path /etc/puppet/modules