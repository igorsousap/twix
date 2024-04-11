defmodule TwixWeb.Resolvers.Post do
  alias Twix
  def create(%{input: params}, _contexct), do: Twix.create_post(params)
  def add_like(%{id: id}, _context), do: Twix.adds_like_to_post(id)
end
