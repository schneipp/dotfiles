return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      sqls = {
        settings = {
          sqls = {
            connections = {
              {
                driver = "postgresql-hrcore",
                dataSourceName = "host=172.17.0.1 port=5432 user=root password=${POSTGRES_PASSWORD} dbname=hrcore sslmode=disable",
              },
              {
                driver = "postgresql-public",
                dataSourceName = "host=172.17.0.1 port=5432 user=root password=${POSTGRES_PASSWORD} dbname=postgres sslmode=disable",
              },
            },
          },
        },
      },
    },
  },
}
