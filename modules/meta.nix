{ lib, ... }:
let
  readonly =
    name:
    lib.mkOption {
      type = lib.types.singleLineStr;
      readOnly = true;
      default = name;
    };
in
{
  options = {
    username = readonly "ephemeral";
    fullname = readonly "Ephemeral";
    # Simple Login Alias
    email = readonly "ephemeral.those316@slmails.com";
  };
}
