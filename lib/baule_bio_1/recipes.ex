defmodule BauleBio1.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false
  alias BauleBio1.Repo

  alias BauleBio1.Recipes.Recipe
  alias BauleBio1.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any recipe changes.

  The broadcasted messages match the pattern:

    * {:created, %Recipe{}}
    * {:updated, %Recipe{}}
    * {:deleted, %Recipe{}}

  """
  def subscribe_recipes(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(BauleBio1.PubSub, "user:#{key}:recipes")
  end

  defp broadcast_recipe(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(BauleBio1.PubSub, "user:#{key}:recipes", message)
  end

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes(scope)
      [%Recipe{}, ...]

  """
  def list_recipes(%Scope{} = scope) do
    Repo.all_by(Recipe, user_id: scope.user.id)
  end

  @doc """
  Returns the list of all approved recipes (public).
  """
  def list_approved_recipes do
    Recipe
    |> where([r], r.status == "approved")
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Returns the list of recipes for a specific user.
  """
  def list_user_recipes(%Scope{} = scope) do
    Recipe
    |> where([r], r.user_id == ^scope.user.id)
    |> preload(:user)
    |> order_by([r], desc: r.inserted_at)
    |> Repo.all()
  end

  @doc """
  Returns the list of pending recipes for admin approval.
  """
  def list_pending_recipes do
    Recipe
    |> where([r], r.status == "pending")
    |> preload(:user)
    |> order_by([r], asc: r.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single recipe.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_recipe!(scope, 123)
      %Recipe{}

      iex> get_recipe!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_recipe!(%Scope{} = scope, id) do
    Repo.get_by!(Recipe, id: id, user_id: scope.user.id)
  end

  @doc """
  Gets a single approved recipe (public access).
  """
  def get_approved_recipe!(id) do
    Recipe
    |> where([r], r.id == ^id and r.status == "approved")
    |> preload(:user)
    |> Repo.one!()
  end

  @doc """
  Gets any recipe (admin access).
  """
  def get_any_recipe!(id) do
    Recipe
    |> where([r], r.id == ^id)
    |> preload(:user)
    |> Repo.one!()
  end

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(scope, %{field: value})
      {:ok, %Recipe{}}

      iex> create_recipe(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(%Scope{} = scope, attrs) do
    with {:ok, recipe = %Recipe{}} <-
           %Recipe{}
           |> Recipe.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_recipe(scope, {:created, recipe})
      {:ok, recipe}
    end
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(scope, recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(scope, recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Scope{} = scope, %Recipe{} = recipe, attrs) do
    true = recipe.user_id == scope.user.id

    with {:ok, recipe = %Recipe{}} <-
           recipe
           |> Recipe.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_recipe(scope, {:updated, recipe})
      {:ok, recipe}
    end
  end

  @doc """
  Deletes a recipe.

  ## Examples

      iex> delete_recipe(scope, recipe)
      {:ok, %Recipe{}}

      iex> delete_recipe(scope, recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recipe(%Scope{} = scope, %Recipe{} = recipe) do
    true = recipe.user_id == scope.user.id

    with {:ok, recipe = %Recipe{}} <-
           Repo.delete(recipe) do
      broadcast_recipe(scope, {:deleted, recipe})
      {:ok, recipe}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(scope, recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Scope{} = scope, %Recipe{} = recipe, attrs \\ %{}) do
    true = recipe.user_id == scope.user.id

    Recipe.changeset(recipe, attrs, scope)
  end

  @doc """
  Approves or rejects a recipe (admin only).
  """
  def update_recipe_status(%Recipe{} = recipe, status) when status in ["approved", "rejected"] do
    recipe
    |> Ecto.Changeset.change(status: status)
    |> Repo.update()
  end

  @doc """
  Returns a changeset for public recipe creation/editing.
  """
  def change_public_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset_without_scope(recipe, attrs)
  end
end
