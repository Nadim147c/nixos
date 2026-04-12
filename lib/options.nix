final: lib:
let

  inherit (lib)
    mkOption
    types
    ;

  createOption =
    type: default:
    mkOption {
      inherit type default;
    };
in
{
  inherit createOption;
  pkg = default: createOption types.package default;
  bool = default: createOption types.bool default;
  num = default: createOption types.number default;
  int = default: createOption types.int default;
  line = default: createOption types.singleLineStr default;
  str = default: createOption types.str default;
  block = default: createOption lib.types.lines default;

  null =
    let
      option = type: default: createOption (types.nullOr type) default;
    in
    {
      pkg = default: option types.package default;
      bool = default: option types.bool default;
      num = default: option types.number default;
      int = default: option types.int default;
      line = default: option types.singleLineStr default;
      str = default: option types.str default;
      block = default: option lib.types.lines default;
    };

  attrs =
    let
      option = type: default: createOption (types.attrsOf type) default;
    in
    {
      any = default: createOption types.attrs default;
      pkg = default: option types.package default;
      bool = default: option types.bool default;
      num = default: option types.number default;
      int = default: option types.int default;
      line = default: option types.singleLineStr default;
      str = default: option types.str default;
      block = default: option lib.types.lines default;
    };

  list =
    let
      option = type: default: createOption (types.listOf type) default;
    in
    {
      pkg = default: option types.package default;
      bool = default: option types.bool default;
      num = default: option types.number default;
      int = default: option types.int default;
      line = default: option types.singleLineStr default;
      str = default: option types.str default;
      block = default: option lib.types.lines default;
    };
}
