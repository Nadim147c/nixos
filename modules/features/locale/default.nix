{ config, ... }:
{
  flake.modules.nixos.base = {
    time.timeZone = "Asia/Dhaka";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings.LC_ALL = "en_US.UTF-8";
  };
}
