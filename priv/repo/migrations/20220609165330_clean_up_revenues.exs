defmodule Infigonia.Repo.Migrations.CleanUpRevenues do
  use Ecto.Migration

  def change do
    alter table("revenues") do
      remove :others

      add :random1, :string
      add :random2, :string
      add :random3, :string
      add :random4, :string
    end
  end
end
