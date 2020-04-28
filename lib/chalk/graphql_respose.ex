defmodule Chalk.GraphQLRespose do
  @moduledoc """
  Response struct to graphql responses
  """
  defstruct [:data, :errors]
  @type t :: %__MODULE__{data: map(), errors: map()}

  @doc """
  It builds a struct with the GraphQL response. It returs a map with either `:ok` or `:error`

  ##Arguments:

    *raw_response, a map with grapql response that comes from HTTP request

  ##Examples:

    iex> Response.build(%{data: %{"name" => "test_name"}})
    %Response%{data: %{"name" => "test_name"}}

    iex> Response.build(%{errors: %{"name" => "test_name"}})
    %Response%{errors: []}
  """
  @spec build(raw_response :: map()) :: {:ok | :error, t()}
  def build(raw_response = %{data: _}), do: {:ok, struct!(__MODULE__, raw_response)}
  def build(raw_response = %{errors: _}), do: {:error, struct!(__MODULE__, raw_response)}
end
