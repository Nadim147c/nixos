// Do not need to convert this into a package
package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	config, err := os.UserConfigDir()
	if err != nil {
		panic(err)
	}
	expr := fmt.Sprintf(`
    let pkgs = import <nixpkgs> { }; in
    builtins.readFile %s/equibop/settings/settings.json
    |> builtins.fromJSON
    |> pkgs.lib.generators.toPretty { }
	`, config)
	pretty, err := exec.Command("nix", "eval", "--impure", "--raw", "--expr", expr).CombinedOutput()
	if err != nil {
		panic(err)
	}
	res := strings.ReplaceAll(string(pretty), " = {\n      enabled = false;\n    };", ".enabled = false;")
	res = strings.ReplaceAll(res, " = {\n      enabled = true;\n    };", ".enabled = true;")
	fmt.Println(res)
}
