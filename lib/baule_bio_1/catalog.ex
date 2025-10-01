defmodule BauleBio1.Catalog do
  @moduledoc """
  The Catalog context.
  """

  import Ecto.Query, warn: false
  alias BauleBio1.Repo

  alias BauleBio1.Catalog.Ingredient
  alias BauleBio1.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any ingredient changes.

  The broadcasted messages match the pattern:

    * {:created, %Ingredient{}}
    * {:updated, %Ingredient{}}
    * {:deleted, %Ingredient{}}

  """
  def subscribe_ingredients(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(BauleBio1.PubSub, "user:#{key}:ingredients")
  end

  defp broadcast_ingredient(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(BauleBio1.PubSub, "user:#{key}:ingredients", message)
  end

  @doc """
  Returns the list of ingredients.

  ## Examples

      iex> list_ingredients(scope)
      [%Ingredient{}, ...]

  """
  def list_ingredients(%Scope{} = scope) do
    Repo.all_by(Ingredient, user_id: scope.user.id)
  end

  @doc """
  Gets a single ingredient.

  Raises `Ecto.NoResultsError` if the Ingredient does not exist.

  ## Examples

      iex> get_ingredient!(scope, 123)
      %Ingredient{}

      iex> get_ingredient!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_ingredient!(_scope, id) do
    Repo.get!(Ingredient, id)
  end

  @doc """
  Creates a ingredient.

  ## Examples

      iex> create_ingredient(scope, %{field: value})
      {:ok, %Ingredient{}}

      iex> create_ingredient(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ingredient(%Scope{} = scope, attrs) do
    with {:ok, ingredient = %Ingredient{}} <-
           %Ingredient{}
           |> Ingredient.changeset(attrs)
           |> Repo.insert() do
      broadcast_ingredient(scope, {:created, ingredient})
      {:ok, ingredient}
    end
  end

  @doc """
  Updates a ingredient.

  ## Examples

      iex> update_ingredient(scope, ingredient, %{field: new_value})
      {:ok, %Ingredient{}}

      iex> update_ingredient(scope, ingredient, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ingredient(%Scope{} = scope, %Ingredient{} = ingredient, attrs) do
    with {:ok, ingredient = %Ingredient{}} <-
           ingredient
           |> Ingredient.changeset(attrs)
           |> Repo.update() do
      broadcast_ingredient(scope, {:updated, ingredient})
      {:ok, ingredient}
    end
  end

  @doc """
  Deletes a ingredient.

  ## Examples

      iex> delete_ingredient(scope, ingredient)
      {:ok, %Ingredient{}}

      iex> delete_ingredient(scope, ingredient)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ingredient(%Scope{} = scope, %Ingredient{} = ingredient) do
    with {:ok, ingredient = %Ingredient{}} <-
           Repo.delete(ingredient) do
      broadcast_ingredient(scope, {:deleted, ingredient})
      {:ok, ingredient}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ingredient changes.

  ## Examples

      iex> change_ingredient(scope, ingredient)
      %Ecto.Changeset{data: %Ingredient{}}

  """
  def change_ingredient(%Ingredient{} = ingredient, attrs \\ %{}) do
    Ingredient.changeset(ingredient, attrs)
  end
end
