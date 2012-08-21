REVERB Sprinkle Stack
=====================

A collection of sprinkle packages for provisioning servers.

## Usage

When running sprinkle from the project root set the `APP_ROOT`, which allows
add_deploy_ssh_keys to find an authorized_keys file in config/authorized_keys by
convention.

    sprinkle -c -s config/install.rb APP_ROOT=`pwd`
