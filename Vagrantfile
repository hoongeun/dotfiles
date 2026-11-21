# Requires an Ubuntu 26.04 Desktop qcow2 image with a vagrant SSH user.
Vagrant.configure("2") do |config|
  config.vm.hostname = "dotfiles-test"
  config.vm.boot_timeout = 600
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.ssh.username = "vagrant"
  config.ssh.private_key_path = ENV.fetch("VAGRANT_SSH_KEY") do
    File.expand_path("~/.local/share/vagrant/ubuntu-26.04-desktop.key")
  end

  config.vm.provider "qemu" do |qemu|
    ssh_port = Integer(ENV.fetch("VAGRANT_VM_SSH_PORT", "50022"))
    raise "Invalid SSH port" unless (1..65_535).cover?(ssh_port)
    qemu.image_path = ENV.fetch("UBUNTU_DESKTOP_IMAGE") do
      File.expand_path("~/.local/share/vagrant/ubuntu-26.04-desktop.qcow2")
    end
    qemu.memory = "6G"
    qemu.smp = "4"
    qemu.ssh_port = ssh_port
    qemu.net_device = nil
    qemu.extra_qemu_args = [
      "-device", "virtio-net-pci,netdev=net0",
      "-netdev", "user,id=net0,hostfwd=tcp:127.0.0.1:#{ssh_port}-:22"
    ]
    qemu.other_default = %w[-parallel none -monitor none -display none -vga virtio]
  end
end
