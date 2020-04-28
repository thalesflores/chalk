defmodule Chalk do
  @moduledoc """
    `Chalk` is a client to make your life easy when you need to request GraphQL API's
  """

  alias __MODULE__.{GraphQLResponse, Request}

  @doc """
  Make a GrahpQL query to a client and returns %GraphQLResponse{} struct

  ## Arguments

    * request_params, a keyword that could contains
      - url, the client url
      - options, keyworkd with options to the request
      - headers, keyworkd with headers to the request, i.e: [{"authorization", "Bearer 234"}]
    * query_params, keyword with params to build the query
    * variables, map with variables that will be uses in the query

  ## Examples

    iex> request_params = [url: "https://test.com/]
    iex> query_params = [users: [:name, :age, friends: [:id, :name]]]
    iex> Chalk.query(request_params, query_params)
    %GraphQLResponse{}

    iex> request_params = [url: "https://test.com/, headers: [{"Authorization", "Bearer 23333"}]]
    iex> query_params = ["User(id: $id)": [:name, :age, friends: [:id, :name]]]
    iex> variables = %{id: 123}
    iex> Chalk.query(request_params, query_params, variables)
    %GraphQLResponse{}
  """
  @spec query(request_params :: keyword(), query_params :: keyword(), variables :: map()) ::
          {:ok | :error, GraphQLResponse.t()} | {:error, {:chalk, :BAD_RESPOSE | :CLIENT_ERROR}}
  def query(request_params, query_params, variables \\ %{}) do
    query =
      query_params
      |> build_query()

    Request.graphql_query(request_params, query, variables)
  end

  @doc """
  It builds a query in format expected in Graphql

  ## Arguments

    * query_params, keyword with params to build the query

  ## Examples

    iex> query_params = [users: [:name, :age, friends: [:id, :name]]]
    iex> Chalk.build_query(query_params)
    "query{users{name age friends{id name}}}"

    iex> query_params = ["User(id: $id)": [:name, :age, friends: [:id, :name]]]
    iex> Chalk.build_query(query_params)
    "query{User(id: $id){name age friends{id name}}}"
  """
  @spec build_query(query_params :: Keyword.t()) :: String.t()
  def build_query(query_params),
    do: query_params |> to_graphql() |> add_curly_braces() |> query_key()

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
