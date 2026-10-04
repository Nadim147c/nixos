final: lib: [ ./gtk.nix ] |> map (path: import path final lib) |> lib.foldl' lib.mergeAttrs { }
