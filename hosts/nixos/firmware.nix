# Only the firmware this laptop loads, not all of linux-firmware (~835 MB).
# The files were found with: journalctl -k -b | grep -i firmware
# New hardware that needs firmware (a USB Wi-Fi dongle...) won't work until
# its files are added here. Undo it all with enableRedistributableFirmware = true.
{ pkgs, ... }:

let
  # Copied from the zstd-compressed linux-firmware the system already uses,
  # so nothing extra is downloaded; it's not compressed a second time.
  linux-firmware-trimmed =
    pkgs.runCommand "linux-firmware-trimmed" { passthru.compressFirmware = false; }
      ''
        cd ${pkgs.compressFirmwareZstd pkgs.linux-firmware}/lib/firmware
        mkdir -p $out/lib/firmware
        # whole families, so newer kernels asking for newer versions still work
        cp -P --parents --no-preserve=mode \
          i915/adlp_* i915/tgl_huc* \
          iwlwifi-so-a0-gf-a0* intel/iwlwifi/iwlwifi-so-a0-gf-a0* \
          intel/ibt-0040-0041.* \
          $out/lib/firmware/
      '';
in
{
  hardware.enableRedistributableFirmware = false;
  hardware.firmware = [
    linux-firmware-trimmed # GPU (i915), Wi-Fi (iwlwifi AX211), Bluetooth
    pkgs.sof-firmware # sound (intel/sof, intel/sof-tplg)
  ];
  # was on through enableRedistributableFirmware
  hardware.cpu.intel.updateMicrocode = true;
  # Wi-Fi channel/power rules per country (regulatory.db); NixOS turns this on
  # for wpa_supplicant but not for iwd
  hardware.wirelessRegulatoryDatabase = true;
}
