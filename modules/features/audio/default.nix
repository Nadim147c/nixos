{ lib, ... }:
let
  inherit (lib.x) singleton;
in
{
  flake.modules.nixos.base = {
    preserveHome.directories = singleton ".local/state/wireplumber";
    services.pipewire = {
      enable = true;
      pulse.enable = true; # replace PulseAudio
      jack.enable = true; # replace JACK
      alsa.enable = true; # replace ALSA
      alsa.support32Bit = true; # for 32-bit apps (e.g., Steam)
    };
  };
}
