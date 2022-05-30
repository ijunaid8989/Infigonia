defmodule Infigonia.Repo.Migrations.Sources do
  use Ecto.Migration

  def change do
    create table("sources") do
      add :url, :string
    end

    create unique_index("sources", [:url])
  end
end
