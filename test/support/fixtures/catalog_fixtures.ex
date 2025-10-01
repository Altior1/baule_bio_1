defmodule BauleBio1.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BauleBio1.Catalog` context.
  """

  @doc """
  Generate a ingredient.
  """
  def ingredient_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        name: "some name"
      })

    {:ok, ingredient} = BauleBio1.Catalog.create_ingredient(scope, attrs)
    ingredient
  end
end
