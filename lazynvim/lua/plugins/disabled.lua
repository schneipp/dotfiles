return {
  -- disable bufferline
  { "akinsho/bufferline.nvim", enabled = false },

  -- disable Mason auto-install of LSP servers
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {},
      automatic_installation = false,
    },
  },

  -- disable Mason auto-install of formatters/linters
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {},
      automatic_installation = false,
    },
  },
}
