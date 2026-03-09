{
  pkgs,
  lib,
  ...
}: {
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

  # Workaround: upstream service hardcodes /usr/bin/sh which doesn't exist on NixOS
  systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
    "" # clear upstream ExecStart first
    "${pkgs.bash}/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | ${pkgs.systemd}/bin/systemd-creds encrypt --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
  ];
}
