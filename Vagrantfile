# -*- mode: ruby -*-
# vi: set ft=ruby :

# This Vagrantfile creates a local 3-node Kubernetes lab:
# - 1 control-plane node
# - 2 worker nodes
#
# CROSS-PLATFORM SUPPORT
# ----------------------
# This setup works on macOS (Intel and Apple Silicon), Linux (x86_64 and ARM),
# and Windows (via WSL — see README for Windows instructions).
#
# The CPU architecture is detected automatically:
#   - Apple Silicon (M1/M2/M3/M4) → arm64 Vagrant box
#   - Intel/AMD Mac, Linux, Windows → x86_64 Vagrant box (no box_architecture set)
#
# Requirements on all platforms:
#   - VirtualBox: https://www.virtualbox.org/wiki/Downloads
#   - Vagrant:    https://developer.hashicorp.com/vagrant/install
#
# NODES = list of servers we want to create
# k8s-control-01 = main Kubernetes node
# k8s-worker-01, k8s-worker-02 = worker nodes where workloads run
# private_network = each server receives a fixed IP address

# Detect the host CPU architecture so the correct Vagrant box is selected.
# 'uname -m' returns 'arm64' on Apple Silicon and 'x86_64' on Intel/AMD.
# On Windows (no uname), the rescue block defaults to x86_64.
HOST_ARCH = begin
  `uname -m 2>/dev/null`.strip
rescue StandardError
  "x86_64"
end

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

  # Only set box_architecture on ARM64 hosts (Apple Silicon Macs).
  # On Intel/AMD machines this option is not needed and should not be set.
  config.vm.box_architecture = "arm64" if HOST_ARCH == "arm64"

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
