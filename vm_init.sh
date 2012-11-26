#!/bin/bash

# Update repos
sudo apt-get update

# Install linux-headers
sudo apt-get -y install linux-headers

# Install TeXLive
sudo apt-get -y install texlive texlive-metapost texlive-latex-extra texlive-lang-cyrillic

# Install gnuplot
sudo apt-get -y install gnuplot

# Install RVM prerequisites
sudo apt-get -y install libyaml-dev git
sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config

# Install RVM (no Ruby)
\curl -L https://get.rvm.io | bash -s stable --ruby=""

# Source RVM to use it
source /home/vagrant/.rvm/scripts/rvm

# Install Ruby
command rvm install ruby
rvm use --default ruby

# Install Rake
gem install rake bundler

# Install dependencies
bundle install
