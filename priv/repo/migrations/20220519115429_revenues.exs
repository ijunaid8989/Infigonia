defmodule Infigonia.Repo.Migrations.Revenues do
  use Ecto.Migration

  def change do
    create table("revenues") do
      add :revenue, :decimal
      add :currency, :string
      add :date, :date
      add :others, :map, default: %{}
    end

    create unique_index("revenues", ["(date::date)", :currency, :revenue])
  end
end
