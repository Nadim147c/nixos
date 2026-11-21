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

  recursiveType = types.nullOr (
    types.oneOf [
      types.bool
      types.int
      types.float
      types.str
      types.path
      (types.attrsOf recursiveType)
      (types.listOf recursiveType)
    ]
  );
in
{
  inherit createOption;

  # keep-sorted start
  block = default: createOption types.lines default;
  bool = default: createOption types.bool default;
  int = default: createOption types.int default;
  line = default: createOption types.singleLineStr default;
  num = default: createOption types.number default;
  path = default: createOption types.path default;
  pkg = default: createOption types.package default;
  recursive = default: createOption recursiveType default;
  str = default: createOption types.str default;
  # keep-sorted end

  null =
    let
      option = type: default: createOption (types.nullOr type) default;
    in
    {
      # keep-sorted start
      block = default: option types.lines default;
      bool = default: option types.bool default;
      int = default: option types.int default;
      line = default: option types.singleLineStr default;
      num = default: option types.number default;
      pkg = default: option types.package default;
      recursive = default: option recursiveType default;
      str = default: option types.str default;
      # keep-sorted end
    };

  attrs =
    let
      option = type: default: createOption (types.attrsOf type) default;
    in
    {
      # keep-sorted start
      any = default: createOption types.attrs default;
      block = default: option types.lines default;
      bool = default: option types.bool default;
      int = default: option types.int default;
      line = default: option types.singleLineStr default;
      num = default: option types.number default;
      pkg = default: option types.package default;
      recursive = default: option recursiveType default;
      str = default: option types.str default;
      # keep-sorted end
    };

  list =
    let
      option = type: default: createOption (types.listOf type) default;
    in
    {
      # keep-sorted start
      attrs = default: option types.attrs default;
      block = default: option types.lines default;
      bool = default: option types.bool default;
      int = default: option types.int default;
      line = default: option types.singleLineStr default;
      num = default: option types.number default;
      path = default: option types.path default;
      pkg = default: option types.package default;
      recursive = default: option recursiveType default;
      str = default: option types.str default;
      # keep-sorted end
    };
}
