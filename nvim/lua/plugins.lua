-- [[ plugins.lua ]]

-- Helper to see if plugin manager is present, and if not grab a copy of the
-- most recent version. Returns a bool describing whether or not packer needed to
-- be initialized.
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end

  return false
end

-- Run the actual insurance method, this 
local packer_bootstrap = ensure_packer()

-- Configure our now guaranteed package management utility.
return require('packer').startup(function(use)
	-- Have the plugin manager manage itself as well...
	use 'wbthomason/packer.nvim'

	-- Language server plugins
	-- use 'neovim/nvim-lspconfig'
	-- use 'simrat39/rust-tools.nvim'

	-- Active debugging plugins
	-- use 'nvim-lua/plenary.nvim' -- might be required for some rust-tools functionality, came from their installation instructions
	-- use 'mfussenegger/nvim-dap' -- required by rust-tools

	-- If packer needed to be bootstrapped during this run, we also want to
	-- grab all our other plugins and make sure we have them present as well
	if packer_bootstrap then
		require('packer').sync()
	end
end)
