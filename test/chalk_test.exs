defmodule ChalkTest do
  use ExUnit.Case

  describe "query/1" do
    test "when passed a simple query and returns in graphql format" do
      params = [get_users: [:name, :age]]
      expected_response = "{getUsers{name age}}"

      assert expected_response == Chalk.query(params)
    end

    test "when passed a query with subquery and returns in graphql format" do
      params = [get_users: [:name, :age, posts: [:another_data]], visits: [:total]]
      expected_response = "{getUsers{name age posts{anotherData}}visits{total}}"

      assert expected_response == Chalk.query(params)
    end
  end
end
