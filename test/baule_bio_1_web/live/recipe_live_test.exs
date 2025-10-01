defmodule BauleBio1Web.RecipeLiveTest do
  use BauleBio1Web.ConnCase

  import Phoenix.LiveViewTest
  import BauleBio1.RecipesFixtures

  @create_attrs %{status: "some status", instructions: "some instructions", description: "some description", title: "some title", prep_time: 42, cook_time: 42, servings: 42}
  @update_attrs %{status: "some updated status", instructions: "some updated instructions", description: "some updated description", title: "some updated title", prep_time: 43, cook_time: 43, servings: 43}
  @invalid_attrs %{status: nil, instructions: nil, description: nil, title: nil, prep_time: nil, cook_time: nil, servings: nil}

  setup :register_and_log_in_user

  defp create_recipe(%{scope: scope}) do
    recipe = recipe_fixture(scope)

    %{recipe: recipe}
  end

  describe "Index" do
    setup [:create_recipe]

    test "lists all recipes", %{conn: conn, recipe: recipe} do
      {:ok, _index_live, html} = live(conn, ~p"/recipes")

      assert html =~ "Listing Recipes"
      assert html =~ recipe.title
    end

    test "saves new recipe", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/recipes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Recipe")
               |> render_click()
               |> follow_redirect(conn, ~p"/recipes/new")

      assert render(form_live) =~ "New Recipe"

      assert form_live
             |> form("#recipe-form", recipe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#recipe-form", recipe: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/recipes")

      html = render(index_live)
      assert html =~ "Recipe created successfully"
      assert html =~ "some title"
    end

    test "updates recipe in listing", %{conn: conn, recipe: recipe} do
      {:ok, index_live, _html} = live(conn, ~p"/recipes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#recipes-#{recipe.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/recipes/#{recipe}/edit")

      assert render(form_live) =~ "Edit Recipe"

      assert form_live
             |> form("#recipe-form", recipe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#recipe-form", recipe: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/recipes")

      html = render(index_live)
      assert html =~ "Recipe updated successfully"
      assert html =~ "some updated title"
    end

    test "deletes recipe in listing", %{conn: conn, recipe: recipe} do
      {:ok, index_live, _html} = live(conn, ~p"/recipes")

      assert index_live |> element("#recipes-#{recipe.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#recipes-#{recipe.id}")
    end
  end

  describe "Show" do
    setup [:create_recipe]

    test "displays recipe", %{conn: conn, recipe: recipe} do
      {:ok, _show_live, html} = live(conn, ~p"/recipes/#{recipe}")

      assert html =~ "Show Recipe"
      assert html =~ recipe.title
    end

    test "updates recipe and returns to show", %{conn: conn, recipe: recipe} do
      {:ok, show_live, _html} = live(conn, ~p"/recipes/#{recipe}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/recipes/#{recipe}/edit?return_to=show")

      assert render(form_live) =~ "Edit Recipe"

      assert form_live
             |> form("#recipe-form", recipe: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#recipe-form", recipe: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/recipes/#{recipe}")

      html = render(show_live)
      assert html =~ "Recipe updated successfully"
      assert html =~ "some updated title"
    end
  end
end
