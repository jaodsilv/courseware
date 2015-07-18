#!/bin/bash
# This script is designed for Ubuntu 12.04
# Should mostly work on 11.10 except Heroku install but not tested
# run with . <filename>.sh

# Get password to be used with sudo commands
# Script still requires password entry during rvm and heroku installs
echo -n "Enter password to be used for sudo commands:"
read -s password

# Function to issue sudo command with password
function sudo-pw {
    echo $password | sudo -S $@
}

# Show commands as they are executed, useful for debugging
# turned off in some areas to avoid logging other scripts
set -v

# Store current stdout and stderr in file descriptors 3 and 4
# If breaking out of script before complete, restart terminal
# to restore proper descriptors
exec 3>&1
exec 4>&2

# Capture all output and errors in config_log.txt for debugging
# in case of errors or failed installs due to network or other issues
exec > >(tee config_log.txt)
exec 2>&1

# Start configuration
cd ~/
sudo-pw yum update
sudo-pw yum install -y dkms     # For installing VirtualBox guest additions

# add profile to bash_profile as recommended by rvm
touch ~/.bash_profile
echo "source ~/.profile" >> ~/.bash_profile

# Install RVM and ruby 1.9.3 note: may take a while to compile ruby
sudo-pw yum install -y curl
# Get mpapis' pubkey per https://rvm.io/rvm/security
gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
set +v
curl -L https://get.rvm.io | bash -s stable --ruby=1.9.3
source ~/.rvm/scripts/rvm

# reload profile to set paths for gem and rvm commands
source ~/.bash_profile
set -v

# remove warning when having ruby version in Gemfile so Heroku uses correct version
rvm rvmrc warning ignore allGemfiles

# Install sqlite3 dev
sudo-pw yum -y install sqlite libsqlite3x-devel

# Install required libs and optional feedvalidator for typo homework
sudo-pw yum -y install libxml2-devel libxslt-devel
# sudo-pw yum -y install python-feedvalidator

# Install nodejs
sudo-pw yum install -y nodejs

# Install jslint
set +v
cd ~/
curl -LO http://www.javascriptlint.com/download/jsl-0.3.0-src.tar.gz
tar -zxvf jsl-0.3.0-src.tar.gz
cd jsl-0.3.0/src/
make -f Makefile.ref
cd ~/
sudo-pw cp jsl-0.3.0/src/Linux_All_DBG.OBJ/jsl /usr/local/bin
sudo-pw rm jsl-0.3.0-src.tar.gz
sudo-pw rm -rf ~/jsl-0.3.0
set -v

# Install other programs
sudo-pw yum install -y git
# sudo-pw yum install -y chromium-browser
sudo-pw yum install -y graphviz
sudo-pw yum install -y libpqxx-devel

## GEMS

# install rails 3.2.16
gem install rails -v 3.2.16

# sqlite 3 gem
gem install sqlite3

# other gems: for testing and debugging....
gem install cucumber -v 1.3.8
gem install cucumber-rails -v 1.3.1
gem install cucumber-rails-training-wheels
gem install rspec
gem install rspec-rails
gem install autotest
gem install spork
gem install metric_fu
gem install debugger
gem install timecop -v 0.6.3
gem install chronic -v 0.9.1
# for app development...
gem install omniauth
gem install omniauth-twitter
gem install nokogiri
gem install themoviedb -v 0.0.17
gem install ruby-graphviz
gem install reek
gem install flog
gem install flay
set +v
rvm 1.9.3 do gem install jquery-rails
set -v
gem install fakeweb

wget -O- https://toolbelt.heroku.com/install.sh | sh

# Restore stdout and stderr and close file descriptors 3 and 4
exec 1>&3 3>&-
exec 2>&4 4>&-

# turn off echo
set +v

# NOTE: you will need to run `source ~/.rvm/scripts/rvm` or similar (see the output from the script) to have access to your gems etc.
