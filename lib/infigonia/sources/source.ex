defmodule Infigonia.Sources.Source do
  use Ecto.Schema

  alias Infigonia.Repo

  import Ecto.{Changeset, Query}

  schema "sources" do
    field(:url, :string)
  end

  @spec insert(String.t()) :: %Infigonia.Sources.Source{} | Ecto.Changeset.t()
  def insert(source) do
    %Infigonia.Sources.Source{}
    |> changeset(%{url: source})
    |> Repo.insert(on_conflict: :nothing)
  end

  @spec sources :: list(%Infigonia.Sources.Source{})
  def sources() do
    Infigonia.Sources.Source
    |> order_by(asc: :url)
    |> Repo.all()
  end

  @spec changeset(
          {map, map}
          | %{
              :__struct__ => atom | %{:__changeset__ => map, optional(any) => any},
              optional(atom) => any
            },
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url])
    |> validate_required([:url])
  end
end
