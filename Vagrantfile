# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

ENV['VAGRANT_DEFAULT_PROVIDER'] ||= 'lxc'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "fgrehm/trusty64-lxc"

  config.vm.provision :shell, path: 'dependencies.sh'
  config.vm.provision :puppet
end