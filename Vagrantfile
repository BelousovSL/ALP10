# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_SERVER_URL'] = 'https://vagrant.elab.pro'
Vagrant.configure("2") do |config|
    config.vm.define "belousovSystemD" do |belousovSystemD|
        belousovSystemD.vm.box = "bento/ubuntu-24.04"                      
        belousovSystemD.vm.host_name = "belousovSystemD"
        belousovSystemD.vm.provision "shell", path: "init.sh"
        belousovSystemD.vm.provider "virtualbox" do |vb|
         vb.memory = "1024"
         vb.cpus = "2"
       end 
    end
 end