defmodule ChalkTest do
  use ExUnit.Case, async: true

  describe "build_query/2" do
    test "when passed a simple query and returns in graphql format" do
      params = [get_users: [:name, :age]]
      expected_response = "query{getUsers{name age}}"

      assert expected_response == Chalk.build_query(params)
    end

    test "when passed a query with subquery and returns in graphql format" do
      params = [get_users: [:name, :age, posts: [:another_data]], visits: [:total]]
      expected_response = "query{getUsers{name age posts{anotherData}}visits{total}}"

      assert expected_response == Chalk.build_query(params)
    end
  end

  describe "query/3" do
    setup do
      %{bypass: Bypass.open()}
    end

    test "when passed valid url, params and returns graphql response", %{bypass: bypass} do
      Bypass.expect(bypass, &Plug.Conn.resp(&1, 200, query_response(:success)))

      params = [countries: [:code, :name, :capital, languages: [:code, :name]]]

      assert {:ok, %Chalk.GraphQLResponse{data: data, errors: nil}} =
               Chalk.query([url: endpoint(bypass)], params)

      assert is_map(data)
    end

    test "when passed valid params but client response error and returns graphql response", %{
      bypass: bypass
    } do
      Bypass.expect(bypass, &Plug.Conn.resp(&1, 200, query_response(:fail)))

      params = [countries: [:code, :name, :error, languages: [:code, :name]]]

      assert {:error, %Chalk.GraphQLResponse{data: nil, errors: errors}} =
               Chalk.query([url: endpoint(bypass)], params)

      assert is_list(errors)
    end

    test "when client returns status code different from 200 and returns :BAD_RESPONSE", %{
      bypass: bypass
    } do
      Bypass.expect(bypass, &Plug.Conn.resp(&1, 201, query_response(:success)))
      params = [countries: [:code, :name, :capital, languages: [:code, :name]]]

      assert {:error, {:chalk, :BAD_RESPONSE, error: error}} =
               Chalk.query([url: endpoint(bypass)], params)

      refute is_nil(error)
    end

    test "when client response with error and returns :CLIENT_ERROR" do
      params = [countries: [:code, :name, :capital, languages: [:code, :name]]]

      assert {:error, {:chalk, :CLIENT_ERROR, error: error}} =
               Chalk.query([url: "http://localhost:0"], params)

      refute is_nil(error)
    end
  end

  defp endpoint(bypass), do: "http://localhost:#{bypass.port}/"

  defp query_response(:success) do
    Poison.encode!(%{
      data: %{
        countries: [
          %{
            code: "AD",
            name: "Andorra",
            capital: "Andorra la Vella",
            languages: [
              %{
                code: "ca",
                name: "Catalan"
              }
            ]
          },
          %{
            code: "AE",
            name: "United Arab Emirates",
            capital: "Abu Dhabi",
            languages: [
              %{
                code: "ar",
                name: "Arabic"
              }
            ]
          },
          %{
            code: "AF",
            name: "Afghanistan",
            capital: "Kabul",
            languages: [
              %{
                code: "ps",
                name: "Pashto"
              },
              %{
                code: "uz",
                name: "Uzbek"
              },
              %{
                code: "tk",
                name: "Turkmen"
              }
            ]
          }
        ]
      }
    })
  end

  defp query_response(:fail) do
    Poison.encode!(%{
      errors: [
        %{
          message: "Cannot query field \"error\" on type \"Country\".",
          locations: [
            %{
              line: 1,
              column: 17
            }
          ],
          extensions: %{
            code: "GRAPHQL_VALIDATION_FAILED"
          }
        }
      ]
    })
  end
end
