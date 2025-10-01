defmodule BauleBio1.RecipesTest do
  use BauleBio1.DataCase

  alias BauleBio1.Recipes

  describe "recipes" do
    alias BauleBio1.Recipes.Recipe

    import BauleBio1.AccountsFixtures, only: [user_scope_fixture: 0]
    import BauleBio1.RecipesFixtures

    @invalid_attrs %{status: nil, instructions: nil, description: nil, title: nil, prep_time: nil, cook_time: nil, servings: nil}

    test "list_recipes/1 returns all scoped recipes" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      other_recipe = recipe_fixture(other_scope)
      assert Recipes.list_recipes(scope) == [recipe]
      assert Recipes.list_recipes(other_scope) == [other_recipe]
    end

    test "get_recipe!/2 returns the recipe with given id" do
      scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      other_scope = user_scope_fixture()
      assert Recipes.get_recipe!(scope, recipe.id) == recipe
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(other_scope, recipe.id) end
    end

    test "create_recipe/2 with valid data creates a recipe" do
      valid_attrs = %{status: "some status", instructions: "some instructions", description: "some description", title: "some title", prep_time: 42, cook_time: 42, servings: 42}
      scope = user_scope_fixture()

      assert {:ok, %Recipe{} = recipe} = Recipes.create_recipe(scope, valid_attrs)
      assert recipe.status == "some status"
      assert recipe.instructions == "some instructions"
      assert recipe.description == "some description"
      assert recipe.title == "some title"
      assert recipe.prep_time == 42
      assert recipe.cook_time == 42
      assert recipe.servings == 42
      assert recipe.user_id == scope.user.id
    end

    test "create_recipe/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.create_recipe(scope, @invalid_attrs)
    end

    test "update_recipe/3 with valid data updates the recipe" do
      scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      update_attrs = %{status: "some updated status", instructions: "some updated instructions", description: "some updated description", title: "some updated title", prep_time: 43, cook_time: 43, servings: 43}

      assert {:ok, %Recipe{} = recipe} = Recipes.update_recipe(scope, recipe, update_attrs)
      assert recipe.status == "some updated status"
      assert recipe.instructions == "some updated instructions"
      assert recipe.description == "some updated description"
      assert recipe.title == "some updated title"
      assert recipe.prep_time == 43
      assert recipe.cook_time == 43
      assert recipe.servings == 43
    end

    test "update_recipe/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      recipe = recipe_fixture(scope)

      assert_raise MatchError, fn ->
        Recipes.update_recipe(other_scope, recipe, %{})
      end
    end

    test "update_recipe/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Recipes.update_recipe(scope, recipe, @invalid_attrs)
      assert recipe == Recipes.get_recipe!(scope, recipe.id)
    end

    test "delete_recipe/2 deletes the recipe" do
      scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      assert {:ok, %Recipe{}} = Recipes.delete_recipe(scope, recipe)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(scope, recipe.id) end
    end

    test "delete_recipe/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      assert_raise MatchError, fn -> Recipes.delete_recipe(other_scope, recipe) end
    end

    test "change_recipe/2 returns a recipe changeset" do
      scope = user_scope_fixture()
      recipe = recipe_fixture(scope)
      assert %Ecto.Changeset{} = Recipes.change_recipe(scope, recipe)
    end
  end
end
