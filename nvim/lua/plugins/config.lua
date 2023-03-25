-- Setup Mason language server
require('mason').setup({})
require('mason-lspconfig').setup()

-- Setup rust tooling
require('rust-tools').setup()
