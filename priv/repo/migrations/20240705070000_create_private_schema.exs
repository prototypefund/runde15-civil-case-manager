defmodule CaseManager.Repo.Migrations.CreatePrivateSchema do
  use Ecto.Migration

  def up do
    execute "CREATE SCHEMA IF NOT EXISTS private"
  end

  def down do
    execute "DROP SCHEMA private"
  end
end
