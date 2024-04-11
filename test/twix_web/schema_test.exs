defmodule TwixWeb.SchemaTest do
  use TwixWeb.ConnCase, async: true

  describe "users_query" do
    test "return a user", %{conn: conn} do
      user_params = %{nickname: "Jose", age: "22", email: "jose@teste.com"}

      {:ok, user} = Twix.create_user(user_params)

      query = """
      {
       user(id: #{user.id}){
         nickname
         email
       }
      }
      """

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "data" => %{
                 "user" => %{
                   "email" => "jose@teste.com",
                   "nickname" => "Jose"
                 }
               }
             }
    end

    test "when there is an error, return error", %{conn: conn} do
      user_params = %{nickname: "Jose", age: "22", email: "jose@teste.com"}

      {:ok, user} = Twix.create_user(user_params)

      query = """
      {
       user(id: 999){
         nickname
         email
       }
      }
      """

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "data" => %{"user" => nil},
               "errors" => [
                 %{
                   "locations" => [%{"column" => 2, "line" => 2}],
                   "message" => "not_found",
                   "path" => ["user"]
                 }
               ]
             }
    end
  end

  describe "users mutation" do
    test "when all params are valid, create the user", %{conn: conn} do
      query = """
      mutation{
      createUser(input: {nickname: "Pedro", email: "pedro@sousa,com", age: 22}){
        nickname
        id
      }
      }
      """

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(200)

      assert %{
               "data" => %{
                 "createUser" => %{
                   "id" => _id,
                   "nickname" => "Pedro"
                 }
               }
             } = response
    end
  end

  describe "users subscription" do
    test "return subscrtion test", %{socket: socket} do
      user_params = %{nickname: "Jose", age: "22", email: "jose@teste.com"}

      {:ok, user1} = Twix.create_user(user_params)

      user_params = %{nickname: "pedro", age: "22", email: "pedro@teste.com"}

      {:ok, user2} = Twix.create_user(user_params)

      mutation = """
      mutation{
        addFollower(input: {userId: #{user1.id}, followerId: #{user2.id}){
          followerId
          followingId
        }
      }
      """

      subscription = """
      subscription{
        newFollow{
          followerId
          followingId
        }
      }
      """

      # setup subscription
      socket_ref = push_doc(socket, subscription)
      assert_reply socket_ref, :ok, %{subscriotionId: subscription.id}

      # Setup mutation
      socket_ref = push_doc(socket, mutation)
      assert_reply socket_ref, :ok, mutation_response

      assert =
        mutation_response == %{
          data: %{
            "addFollower" => %{"followerId" => "#{user2.id}", "followingId" => "#{user1.id}"}
          }
        }

      assert_push "subscription:data", subscription_response

      assert subscription_response = %{
               result: %{
                 data: %{
                   "newFollow" => %{"followerId" => "#{user2.id}", "followingId" => "#{user1.id}"}
                 }
               },
               subscriptionId: _subscriptionId
             }
    end
  end
end
