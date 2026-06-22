# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrantfile creates a local 3-node Kubernetes lab:
# - 1 control-plane node
# - 2 worker nodes
#
# Vagrantfile = receipe for creating and configuring virtual machines using Vagrant

# NODES = list of servers we want to create

# k8s-control-01 = main Kubernetes node
# k8s-worker-01 a k8s-worker-02 = worker nodes, where workloads will run

# private_network = each server will receive a fixed IP address

NODES = [
  {
    name: "k8s-control-01",
    ip: "192.168.56.10",
    memory: 2048,
    cpus: 2
  },
  {
    name: "k8s-worker-01",
    ip: "192.168.56.11",
    memory: 2048,
    cpus: 2
  },
  {
    name: "k8s-worker-02",
    ip: "192.168.56.12",
    memory: 2048,
    cpus: 2
  }
]

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_architecture = "arm64"

  # Local lab simplification:
  # keep the default Vagrant SSH key so Ansible can easily connect to all VMs
  # For production-like environments, unique SSH keys would be preferred
  config.ssh.insert_key = false

  # We do not need the repository synced into each VM
  # Ansible will configure the VMs remotely from the Mac
  config.vm.synced_folder ".", "/vagrant", disabled: true

  NODES.each do |node|
    config.vm.define node[:name] do |node_config|
      node_config.vm.hostname = node[:name]

      node_config.vm.network "private_network", ip: node[:ip]

      node_config.vm.provider "virtualbox" do |vb|
        vb.name = node[:name]
        vb.cpus = node[:cpus]
        vb.memory = node[:memory]
      end
    end
  end
end
