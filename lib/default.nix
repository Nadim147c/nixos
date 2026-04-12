# NOTE: all of these utility function is avaialbe under lib.x
final: lib:
let
  inherit (lib)
    genAttrs
    getExe
    getExe'
    toList
    ;

  inherit (lib.strings) splitString toInt;
  inherit (builtins)
    fromJSON
    head
    isFloat
    isInt
    isString
    ;
in
rec {
  opt = (import ./options.nix) final lib;

  isEmpty = list: (builtins.length list) == 0;
  isNotEmpty = list: (builtins.length list) == 0;

  qoute = x: ''"${x}"'';

  # Check if input is a number
  isNumber = v: isInt v || isFloat v;

  # Converts the input to a float if possible (hacky but it works)
  toFloat =
    v:
    let
      strVal = fromJSON v;
      forceFloat = i: if isFloat i then i else i + 0.5 - 0.5;
    in
    assert (isNumber v || isString v);
    if isString v then
      forceFloat strVal
    else if isInt v then
      forceFloat v
    else
      v;

  # Round float to lower integer
  floor =
    f:
    let
      floatComponents = splitString "." (toString f);
      int = toInt (head floatComponents);
    in
    assert (isFloat f);
    int;

  # Round float to upper integer
  ceil =
    f:
    let
      int = div' f 1;
      inc = if mod' f 1 > 0 then 1 else 0;
    in
    assert (isFloat f);
    int + inc;

  # Round float to closest integer
  round =
    f:
    let
      int = div' f 1;
      inc = if mod' f 1 >= 0.5 then 1 else 0;
    in
    assert (isFloat f);
    int + inc;

  # Integer division for floats
  div' =
    n: d:
    assert (isNumber n);
    assert (isNumber d);
    floor (builtins.div (toFloat n) (toFloat d));

  # Module operator implementation for floats
  mod' =
    n: d:
    let
      f = div' n d;
    in
    assert (isNumber n);
    assert (isNumber d);
    n - (toFloat f) * d;

  /*
    cut :: string -> string -> attrset

    Cut string int two prefix and content
  */
  cut =
    sep: str:
    let
      len = builtins.stringLength str;
      sepLen = builtins.stringLength sep;

      go =
        idx: prefix:
        if idx >= len then
          {
            inherit prefix;
            content = "";
          }
        else
          let
            rest = builtins.substring idx (len - idx) str;
          in
          if (builtins.substring 0 sepLen rest) == sep then
            {
              inherit prefix;
              content = builtins.substring (idx + sepLen) (len - idx - sepLen) str;
            }
          else
            go (idx + 1) (prefix + builtins.substring idx 1 str);
    in
    go 0 "";

  /*
    wrapUWSM :: string | package -> string

    Wrap a program so it is launched via `uwsm app --`.

    The result is a shell command string.
  */
  wrapUWSM =
    pkgs: pkg:
    let
      exe = if builtins.isString pkg then pkg else getExe pkg;
    in
    "${getExe pkgs.uwsm} app -- ${exe}";

  /*
    wrapUWSM :: package -> string

    Wrap a program so it is launched via `uwsm app --`.

    The result is a shell command string.
  */
  wrapUWSM' =
    pkgs: pkg: name:
    "${getExe pkgs.uwsm} app -- ${getExe' pkg name}";

  /*
    flakePackage :: attrs -> package

    Get the default package from a flake.
  */
  flakePackage = pkgs: flake: flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  /*
      wrapLocal :: package -> package

    /*
      genMimes :: string | [string] -> [string] -> attrset

      Generate XDG MIME associations for desktop entries.

      Arguments:
      - desktops: a desktop file name or a list of desktop file names
      - types: a list of MIME types

      For each MIME type, the given desktop entries are:
      - added to `xdg.mimeApps.associations.added`
      - set as the default applications
  */
  genMimes =
    desktops: types:
    let
      mimes = genAttrs types (_: toList desktops);
    in
    {
      associations.added = mimes;
      defaultApplications = mimes;
    };
}
