#!/usr/bin/env bash

apt-key update
apt-get update
apt-get install -y apache2
apt-get install -y maven
apt-get install -y git
apt-get install -y curl


if ! [ -L /var/www ]; then
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi
