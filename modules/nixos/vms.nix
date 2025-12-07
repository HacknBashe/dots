{pkgs, ...}: {
  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["nick"];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        runAsRoot = true;
        package = pkgs.qemu_kvm;
        # ovmf = {
        #   enable = true;
        #   # packages = [
        #   #   (pkgs.OVMF.override {
        #   #     secureBoot = true;
        #   #     tpmSupport = true;
        #   #   })
        #   #   .fd
        #   # ];
        # };
        # swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
