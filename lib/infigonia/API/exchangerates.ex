defmodule Infigonia.API.Exchangerates do
  @spec latest :: %{:datetime => DateTime.t(), :rates => [map()]} | []
  def latest() do
    headers = [apikey: exchangerates_api_key(), Accept: "Application/json; Charset=utf-8"]

    (exchangerates_api_url() <> "?base=USD")
    |> HTTPoison.get(headers, [])
    |> parse_response()
    |> prepare_for_db()
  end

  defp exchangerates_api_key(), do: Application.get_env(:infigonia, :exchangerates_api_key)

  defp exchangerates_api_url(), do: Application.get_env(:infigonia, :exchangerates_api_url)

  defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    Jason.decode!(body, keys: fn key -> String.downcase(key) |> String.to_atom() end)
  end

  defp parse_response(_error), do: []

  defp prepare_for_db([]), do: %{}

  defp prepare_for_db(data) do
    datetime = DateTime.from_unix!(data.timestamp)

    %{datetime: datetime, rates: [data.rates]}
  end
end
