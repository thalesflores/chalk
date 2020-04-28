defmodule Chalk.GraphQLResposeTest do
  use ExUnit.Case, async: true

  alias Chalk.GraphQLRespose

  describe "build/1" do
    test "when passed a success response and returns GraphQLRespose successfully" do
      params = %{data: :success}

      assert {:ok, %GraphQLRespose{data: :success, errors: nil}} == GraphQLRespose.build(params)
    end

    test "when passed response with errros and returns GraphQLRespose with error" do
      params = %{errors: :bad}

      assert {:error, %GraphQLRespose{data: nil, errors: :bad}} == GraphQLRespose.build(params)
    end
  end
end
