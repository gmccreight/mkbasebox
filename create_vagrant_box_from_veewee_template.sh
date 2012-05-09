#!/bin/bash

# ./create_vagrant_box_from_veewee_template.sh

# Create a vagrant box using a veewee template

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------

ruby_version="1.9.3"
veewee_version="0.2.3"
veewee_template_name="ubuntu-12.04-server-amd64"
name_of_box_to_create="precise64"
locally_saved_iso_file="`pwd`/ubuntu-12.04-server-amd64.iso"

#------------------------------------------------------------------------------
# RVM
#------------------------------------------------------------------------------

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
  cd ../..
  exit 1
fi

# # Install the various gems in their own gemset
rvm $ruby_version
rvm --force gemset delete mkbasebox
rvm gemset create mkbasebox
rvm $ruby_version@mkbasebox
gem install bundler
bundle


#------------------------------------------------------------------------------
# Possibly cleanup last installation - needs RVM
#------------------------------------------------------------------------------

if [[ -d ./veewee ]]; then
  cd veewee
  bundle exec vagrant destroy 2>/dev/null
  bundle exec vagrant box remove $name_of_box_to_create 2>/dev/null
  bundle exec veewee vbox destroy $name_of_box_to_create 2>/dev/null
  bundle exec veewee vbox undefine $name_of_box_to_create 2>/dev/null
  cd ..
  rm -rf ./veewee
fi


# #------------------------------------------------------------------------------
# # Install the vagrant box from the template
# #------------------------------------------------------------------------------

mkdir veewee
cd veewee

# if the iso is provided, then soft link it into the .iso folder where veewee
# expects it to be
if [[ -f $locally_saved_iso_file ]] ; then
  mkdir ./iso
  cd ./iso
  ln -s "$locally_saved_iso_file" $(basename "$locally_saved_iso_file")
  cd ..
fi

#Create the new basebox, using a local iso file if it specified and exists
bundle exec veewee vbox define $name_of_box_to_create $veewee_template_name

bundle exec veewee vbox build $name_of_box_to_create
bundle exec veewee vbox validate $name_of_box_to_create
bundle exec vagrant package --base $name_of_box_to_create --output $name_of_box_to_create.box
bundle exec vagrant box add $name_of_box_to_create $name_of_box_to_create.box
rm $name_of_box_to_create.box
