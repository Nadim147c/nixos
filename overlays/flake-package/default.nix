inputs: final: prev: {
  lib = prev.lib // rec {
    flakePackage' = input: name: input.packages.${prev.stdenv.hostPlatform.system}.${name};
    flakePackage = input: flakePackage' input "default";
  };
}
