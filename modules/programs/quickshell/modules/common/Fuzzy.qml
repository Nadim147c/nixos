pragma Singleton
import Quickshell
import "fuzzysort.js" as FuzzySort

// Made by end4. License GPL-v3: ../end4/LICENSE

Singleton {
    function go(...args) {
        return FuzzySort.go(...args);
    }

    function prepare(...args) {
        return FuzzySort.prepare(...args);
    }
}
