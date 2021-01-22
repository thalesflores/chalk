defmodule Chalk.Request do
  @moduledoc """
    This module is responsible to execute the request to a graphql client and handles it response
  """
  use HTTPoison.Base

  alias Chalk.GraphQLResponse

  @doc """
  It executes the graphql request and returns a %GraphQLResponse{} struct with the response

  ## Arguments

    * request_params, a keyword that could contains
      - url
      - headers
      - options
    * query, string formatted as GraphQL query
    * variables, map with variables that will be used in request

  ## Examples

    iex> Request.graphql_query([url: "http://test.com/"], "query{users{name}"}, %{})
    %GraphQLResponse{}

    iex> Request.graphql_query([url: "http://test.com/", headers: [{"authorization", "234"}]], "query{users{name}"}, %{})
    %GraphQLResponse{}
  """
  @spec graphql_query(request_params :: Keyword.t(), String.t(), map()) ::
          GraphQLResponse.t() | {:error, {:chalk, :BAD_RESPOSE | :CLIENT_ERROR}}
  def graphql_query(request_params, query, variables) do
    request_params[:url]
    |> HTTPoison.post(
      format_body(query, variables),
      extract(:headers, request_params) |> default_header(),
      extract(:options, request_params)
    )
    |> handle_response()
  end

  defp format_body(query, %{}), do: Poison.encode!(%{query: query})
  defp format_body(query, variables), do: Poison.encode!(%{query: query, variables: variables})

  defp extract(field, params), do: params[field] || []

  defp default_header(headers),
    do: [{"content-type", "application/json; charset=utf-8"} | headers]

  defp handle_response(response) do
    case response do
      {:ok, %HTTPoison.Response{status_code: status, body: body}} when status == 200 ->
        body
        |> process_body()
        |> GraphQLResponse.build()

      {:ok, %HTTPoison.Response{} = error} ->
        {:error, {:chalk, :BAD_RESPONSE, error: inspect(error)}}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, {:chalk, :CLIENT_ERROR, error: inspect(error)}}
    end
  end

  defp process_body(body) do
    body
    |> Poison.decode!()
    |> Enum.into(%{}, fn {key, value} -> {String.to_existing_atom(key), value} end)
  end
end
