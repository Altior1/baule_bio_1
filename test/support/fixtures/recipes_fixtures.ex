defmodule BauleBio1.RecipesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BauleBio1.Recipes` context.
  """

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        cook_time: 42,
        description: "some description",
        instructions: "some instructions",
        prep_time: 42,
        servings: 42,
        status: "some status",
        title: "some title"
      })

    {:ok, recipe} = BauleBio1.Recipes.create_recipe(scope, attrs)
    recipe
  end
end
