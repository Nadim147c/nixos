{ createKeymapDesc, ... }:
{
  vim = {
    keymaps = [
      # Save the current buffer
      (createKeymapDesc "n" "<C-s>" "<CMD>w<CR>" "Save the current buffer")
      (createKeymapDesc "i" "<C-BS>" "<C-W>" "word delete")

      # Enter Command Mode with ;
      (createKeymapDesc "n" ";" ":" "CMD enter command mode")
      (createKeymapDesc "v" ";" ":" "CMD enter command mode")
      (createKeymapDesc "n" "<Esc>" "<CMD>noh<CR>" "Remove search highlight")

      # Switch window
      (createKeymapDesc "n" "<C-h>" "<C-w>h" "switch window left")
      (createKeymapDesc "n" "<C-l>" "<C-w>l" "switch window right")
      (createKeymapDesc "n" "<C-j>" "<C-w>j" "switch window down")
      (createKeymapDesc "n" "<C-k>" "<C-w>k" "switch window up")

      # Merge the next line with current one without moving the cursor
      (createKeymapDesc "n" "J" "mzJ`z" "Join lines without moving cursor")

      # Put without losing current yank
      (createKeymapDesc "x" "p" ''"_dP'' "Put without losing current yank")

      # Search and replace
      (createKeymapDesc "n" "<leader>sr" ":%s/" "Search and replace for this buffer")
      (createKeymapDesc "x" "<leader>sr" ":s/" "Search and replace for this select")

      # Reload current lua file
      (createKeymapDesc "n" "<leader>ls" "<CMD> source % <CR>" "Reload the current lua file")
      (createKeymapDesc "v" "<leader>ls" "<CMD> source % <CR>" "Reload the current lua file")

      # Lazy keymaps
      (createKeymapDesc "n" "<leader>lR" ":Lazy reload" "Reload a lazy plugin")
      (createKeymapDesc "v" "<leader>lR" ":Lazy reload" "Reload a lazy plugin")
      (createKeymapDesc "n" "<leader>lS" ":Lazy sync" "Sync all lazy plugin")
      (createKeymapDesc "v" "<leader>lS" ":Lazy sync" "Sync all lazy plugin")

      # Toggle Undotree
      (createKeymapDesc "n" "<leader>u" "<CMD> UndotreeToggle <CR>" "Toggle Undotree")

      # Block selection mode
      (createKeymapDesc "n" "<leader>v" "<C-V>" "Block selection mode")
    ];
  };
}
