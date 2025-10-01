defmodule BauleBio1.Recipes.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :title, :string
    field :description, :string
    field :instructions, :string
    field :prep_time, :integer
    field :cook_time, :integer
    field :servings, :integer
    field :status, :string, default: "draft"

    belongs_to :user, BauleBio1.Accounts.User
    many_to_many :ingredients, BauleBio1.Catalog.Ingredient, join_through: "recipe_ingredients"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe, attrs, user_scope) do
    recipe
    |> cast(attrs, [
      :title,
      :description,
      :instructions,
      :prep_time,
      :cook_time,
      :servings,
      :status
    ])
    |> validate_required([
      :title,
      :description,
      :instructions,
      :prep_time,
      :cook_time,
      :servings,
      :status
    ])
    |> put_change(:user_id, user_scope.user.id)
  end
end
