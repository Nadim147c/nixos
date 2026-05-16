_: {
  _module.args.createLuaKeymap = mode: key: action: {
    inherit mode key action;
    lua = true;
  };
  _module.args.createKeymap = mode: key: action: {
    inherit mode key action;
  };
  _module.args.createKeymapDesc = mode: key: action: desc: {
    inherit
      mode
      key
      action
      desc
      ;
  };
}
