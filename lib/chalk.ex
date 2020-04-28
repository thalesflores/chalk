defmodule Chalk do
  @moduledoc """
  Documentation for `Chalk`.
  """

  alias __MODULE__.{GraphQLResponse, Request}

  @spec query(request_params :: keyword(), query_params :: keyword(), variables :: map()) ::
          GraphQLResponse.t() | {:error, {:chalk, :BAD_RESPOSE | :CLIENT_ERROR}}
  def query(request_params, query_params, variables \\ %{}) do
    query =
      query_params
      |> build_query()

    Request.graphql_query(request_params, query, variables)
  end

  @spec build_query(query :: Keyword.t()) :: String.t()
  def build_query(query), do: query |> to_graphql() |> add_curly_braces() |> query_key()

  defp to_graphql(query) when is_list(query) do
    query
    |> Enum.reduce("", fn {action, fields}, acc ->
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

  defp query_key(query), do: "query" <> query
end
