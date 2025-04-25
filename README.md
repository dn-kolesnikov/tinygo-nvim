# TinyGo Neovim Plugin

![TinyGo Logo](https://tinygo.org/images/tinygo-logo.svg)  
_Enhance your TinyGo development workflow in Neovim_

## Features

- 🎯 **Target Management**: Switch between TinyGo targets with single command
- 🔄 **LSP Integration**: Automatic LSP restart on target change
- 🔍 **Target Discovery**: List all available TinyGo targets
- ⚡ **Performance**: Cached target lists for fast completion
- 📝 **Documentation**: Built-in help for target configurations

## Installation

### Using [Lazy.nvim](https://github.com/folke/lazy.nvim)

Add to your Neovim configuration:

```lua
{
  "dn-kolesnikov/tinygo-nvim",
  ft = "go", -- Auto-load only for Go files
  opts = {
    -- Default configuration (no settings required)
  },
  dependencies = {
    "neovim/nvim-lspconfig" -- Required for LSP support
  }
}
```

## Configuration Options

```lua
opts = {
    auto_detect = true, -- Auto-detect TinyGo projects
    verbose_notifications = false, -- Detailed change notifications
    lsp_restart_delay = 150, -- Delay before LSP restart (ms)
}
```

## Key Features

1. Intelligent Autocompletion
   Start typing a target and press <Tab>:

```vim
:TinygoTarget pico<Tab>
```

2. Automatic LSP Handling
   Changing targets automatically:

   - Updates `GOFLAGS` and `GOROOT`
   - Restarts LSP with correct configuration
   - Preserves your original LSP settings

3. Project Awareness
   Detects when you're working in:

   - TinyGo projects (auto-suggests targets)
   - Regular Go projects (shows warning)

## Requirements

- Neovim 0.9.0+
- TinyGo 0.28+ in $PATH
- Working LSP setup (not gopls)

## Troubleshooting

### Common Issues

1. Target not found
   Verify TinyGo installation:

```bash
tinygo targets
```

2. LSP not restarting
   Check LSP client:

```vim
:LspInfo
```

3. Environment not updating
   Debug variables:

```vim
:echo $GOFLAGS
:echo $GOROOT
```

## Development

```bash
git clone https://github.com/dn-kolesnikov/tinygo-nvim.git
cd tinygo-nvim
```

## License

MIT License © 2023 Dmitry Kolesnikov
