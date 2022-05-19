defmodule Infigonia.Revenues do
  use Ecto.Schema

  alias Infigonia.Repo

  import Ecto.Changeset

  @batch_size 65535

  schema "revenues" do
    field(:date, :date)
    field(:currency, :string)
    field(:revenue, :decimal)
    field(:others, :map)
  end

  def insert(revenues) do
    list_of_chunks = Enum.chunk_every(revenues, @batch_size)

    Repo.checkout(
      fn ->
        Enum.each(list_of_chunks, fn rows ->
          Repo.insert_all(Infigonia.Revenues, rows, on_conflict: :nothing)
        end)
      end,
      timeout: :infinity
    )

    :ok
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
    |> cast(params, [:date, :currency, :revenue, :others])
    |> validate_required([:date, :currency, :revenue])
  end
end
