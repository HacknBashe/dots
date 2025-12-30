{pkgs, ...}: {
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["nick"];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        package = pkgs.qemu_kvm;
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
