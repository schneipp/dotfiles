-- Database connections use environment variables for security
-- Set POSTGRES_PASSWORD in your shell environment
local db_password = os.getenv("POSTGRES_PASSWORD") or ""
local db_host = os.getenv("POSTGRES_HOST") or "172.17.0.1"
local db_port = os.getenv("POSTGRES_PORT") or "5432"
local db_user = os.getenv("POSTGRES_USER") or "root"

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
                dataSourceName = string.format(
                  "host=%s port=%s user=%s password=%s dbname=hrcore sslmode=disable",
                  db_host, db_port, db_user, db_password
                ),
              },
              {
                driver = "postgresql-public",
                dataSourceName = string.format(
                  "host=%s port=%s user=%s password=%s dbname=postgres sslmode=disable",
                  db_host, db_port, db_user, db_password
                ),
              },
            },
          },
        },
      },
    },
  },
}
