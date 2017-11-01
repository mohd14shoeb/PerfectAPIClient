#! /usr/bin/env bash

# Update openssl
sudo add-apt-repository ppa:0k53d-karl-f830m/openssl -y
sudo apt-get update -q
sudo apt-get install openssl -y

# Update curl
sudo apt-get build-dep curl -y
mkdir ~/curl
cd ~/curl
wget http://curl.haxx.se/download/curl-7.50.2.tar.bz2
tar -xvjf curl-7.50.2.tar.bz2
cd curl-7.50.2
./configure
make
sudo make install
sudo ldconfig
