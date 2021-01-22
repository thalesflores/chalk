defmodule Chalk.GraphQLResponseTest do
  use ExUnit.Case, async: true

  alias Chalk.GraphQLResponse

  describe "build/1" do
    test "when passed a success response and returns GraphQLResponse successfully" do
      params = %{data: :success}

      assert {:ok, %GraphQLResponse{data: :success, errors: nil}} == GraphQLResponse.build(params)
    end

    test "when passed response with errros and returns GraphQLResponse with error" do
      params = %{errors: :bad}

      assert {:error, %GraphQLResponse{data: nil, errors: :bad}} == GraphQLResponse.build(params)
    end
  end
end
