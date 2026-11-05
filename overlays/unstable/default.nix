inputs: final: prev: {
  unstable = inputs.unstable.legacyPackages.${prev.stdenv.hostPlatform.system};
}
