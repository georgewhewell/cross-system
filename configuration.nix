{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/minimal.nix>
    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
  ];

  nixpkgs.overlays = [(self: super: {
    # dont need, speeds up build
    nix = super.nix.override { withAWS = false; };
    
    # Does not cross-compile...
    alsa-firmware = pkgs.runCommandNoCC "neutered-firmware" {} "mkdir -p $out";
  })];

  # (Failing build in a dep to be investigated)
  security.polkit.enable = false;
  services.udisks2.enable = false;

  # cifs-utils fails to cross-compile
  # Let's simplify this by removing all unneeded filesystems from the image.
  boot.supportedFilesystems = lib.mkForce [ "vfat" ];

  # texinfoInteractive has trouble cross-compiling
  documentation.info.enable = lib.mkForce false;

  # `xterm` is being included even though this is GUI-less.
  # → https://github.com/NixOS/nixpkgs/pull/62852
  services.xserver.desktopManager.xterm.enable = lib.mkForce false;
}
