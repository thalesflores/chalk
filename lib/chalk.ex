defmodule Chalk do
  @moduledoc """
  Documentation for `Chalk`.
  """

  @spec query(params :: keyword()) :: String.t()
  def query(params) do
    params
    |> to_graphql()
    |> add_curly_braces()
  end

  defp to_graphql(query) when is_list(query) do
    Enum.reduce(query, "", fn {action, fields}, acc ->
      acc <> ~s(#{to_camel_case(action)}#{to_graphql_fields(fields)})
    end)
  end

  defp to_graphql(query) when is_tuple(query), do: to_graphql([query])
  defp to_graphql(field) when is_atom(field), do: to_camel_case(field)

  defp to_graphql_fields(query) when is_list(query) do
    for(field <- query, into: "", do: "#{to_graphql(field)} ")
    |> String.trim()
    |> add_curly_braces()
  end

  defp to_camel_case(key) do
    [non_capitalize_word | to_capitalize_words] =
      key
      |> to_string()
      |> String.split("_")

    [non_capitalize_word, Enum.map(to_capitalize_words, &String.capitalize(&1))]
    |> Enum.join("")
  end

  defp add_curly_braces(string) do
    string
    |> String.replace_prefix("", "{")
    |> String.replace_suffix("", "}")
  end
end
