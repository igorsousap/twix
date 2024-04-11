defmodule TwixWeb.Schema.Types.Root do
  use Absinthe.Schema.Notation

  alias Crudry.Middlewares.TranslateErrors
  alias TwixWeb.Resolvers.Post, as: PostResolve
  alias TwixWeb.Resolvers.User, as: UserResolve
  alias Twix.Repo
  alias Twix.Users.User

  import_types TwixWeb.Schema.Types.Post
  import_types TwixWeb.Schema.Types.User

  object :root_query do
    field :user, type: :user do
      arg :id, non_null(:id)

      resolve &UserResolve.get/2
    end

    field :users, list_of(:user) do
      resolve fn _args, _context ->
        {:ok, Repo.all(User)}
      end
    end
  end

  object :root_mutation do
    field :create_post, type: :post do
      arg :input, non_null(:create_post_input)

      resolve &PostResolve.create/2
      middleware TranslateErrors
    end

    field :add_follower, type: :add_follower_response do
      arg :input, non_null(:add_follower_input)

      resolve &UserResolve.add_follower/2
      middleware TranslateErrors
    end

    field :add_like_to_post, type: :post do
      arg :id, non_null(:id)

      resolve &PostResolve.add_like/2
    end

    field :create_user, type: :user do
      arg :input, non_null(:create_user_input)

      resolve &UserResolve.create/2
      middleware TranslateErrors
    end

    field :update_user, type: :user do
      arg :input, non_null(:update_user_input)

      resolve &UserResolve.update/2
      middleware TranslateErrors
    end
  end

  object :root_subscription do
    field :new_follow, :add_follower_response do
      config fn _args, _context -> {:ok, topic: "new_follow_topic"} end
      middleware TranslateErrors
    end
  end
end
