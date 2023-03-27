function safe_setup(plugin_name, opts)
    if packer_plugins[plugin_name] and packer_plugins[plugin_name].loaded then
        return require(plugin_name).setup(opts)
    end

    return {}
end

-- Setup Mason language server
safe_setup('mason')
safe_setup('mason-lspconfig')

-- Setup rust tooling
safe_setup('rust-tools')
