defmodule BauleBio1.CatalogTest do
  use BauleBio1.DataCase

  alias BauleBio1.Catalog

  describe "ingredients" do
    alias BauleBio1.Catalog.Ingredient

    import BauleBio1.AccountsFixtures, only: [user_scope_fixture: 0]
    import BauleBio1.CatalogFixtures

    @invalid_attrs %{name: nil, description: nil}

    test "list_ingredients/1 returns all scoped ingredients" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      other_ingredient = ingredient_fixture(other_scope)
      assert Catalog.list_ingredients(scope) == [ingredient]
      assert Catalog.list_ingredients(other_scope) == [other_ingredient]
    end

    test "get_ingredient!/2 returns the ingredient with given id" do
      scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      other_scope = user_scope_fixture()
      assert Catalog.get_ingredient!(scope, ingredient.id) == ingredient
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_ingredient!(other_scope, ingredient.id) end
    end

    test "create_ingredient/2 with valid data creates a ingredient" do
      valid_attrs = %{name: "some name", description: "some description"}
      scope = user_scope_fixture()

      assert {:ok, %Ingredient{} = ingredient} = Catalog.create_ingredient(scope, valid_attrs)
      assert ingredient.name == "some name"
      assert ingredient.description == "some description"
      assert ingredient.user_id == scope.user.id
    end

    test "create_ingredient/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalog.create_ingredient(scope, @invalid_attrs)
    end

    test "update_ingredient/3 with valid data updates the ingredient" do
      scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description"}

      assert {:ok, %Ingredient{} = ingredient} = Catalog.update_ingredient(scope, ingredient, update_attrs)
      assert ingredient.name == "some updated name"
      assert ingredient.description == "some updated description"
    end

    test "update_ingredient/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)

      assert_raise MatchError, fn ->
        Catalog.update_ingredient(other_scope, ingredient, %{})
      end
    end

    test "update_ingredient/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Catalog.update_ingredient(scope, ingredient, @invalid_attrs)
      assert ingredient == Catalog.get_ingredient!(scope, ingredient.id)
    end

    test "delete_ingredient/2 deletes the ingredient" do
      scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      assert {:ok, %Ingredient{}} = Catalog.delete_ingredient(scope, ingredient)
      assert_raise Ecto.NoResultsError, fn -> Catalog.get_ingredient!(scope, ingredient.id) end
    end

    test "delete_ingredient/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      assert_raise MatchError, fn -> Catalog.delete_ingredient(other_scope, ingredient) end
    end

    test "change_ingredient/2 returns a ingredient changeset" do
      scope = user_scope_fixture()
      ingredient = ingredient_fixture(scope)
      assert %Ecto.Changeset{} = Catalog.change_ingredient(scope, ingredient)
    end
  end
end
