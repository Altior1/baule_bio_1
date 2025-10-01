defmodule BauleBio1Web.RecipeLive.Index do
  use BauleBio1Web, :live_view

  alias BauleBio1.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Recipes
        <:actions>
          <.button variant="primary" navigate={~p"/recipes/new"}>
            <.icon name="hero-plus" /> New Recipe
          </.button>
        </:actions>
      </.header>

      <.table
        id="recipes"
        rows={@streams.recipes}
        row_click={fn {_id, recipe} -> JS.navigate(~p"/recipes/#{recipe}") end}
      >
        <:col :let={{_id, recipe}} label="Title">{recipe.title}</:col>
        <:col :let={{_id, recipe}} label="Description">{recipe.description}</:col>
        <:col :let={{_id, recipe}} label="Instructions">{recipe.instructions}</:col>
        <:col :let={{_id, recipe}} label="Prep time">{recipe.prep_time}</:col>
        <:col :let={{_id, recipe}} label="Cook time">{recipe.cook_time}</:col>
        <:col :let={{_id, recipe}} label="Servings">{recipe.servings}</:col>
        <:col :let={{_id, recipe}} label="Status">{recipe.status}</:col>
        <:action :let={{_id, recipe}}>
          <div class="sr-only">
            <.link navigate={~p"/recipes/#{recipe}"}>Show</.link>
          </div>
          <.link navigate={~p"/recipes/#{recipe}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, recipe}}>
          <.link
            phx-click={JS.push("delete", value: %{id: recipe.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Recipes.subscribe_recipes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Recipes")
     |> stream(:recipes, list_recipes(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(socket.assigns.current_scope, id)
    {:ok, _} = Recipes.delete_recipe(socket.assigns.current_scope, recipe)

    {:noreply, stream_delete(socket, :recipes, recipe)}
  end

  @impl true
  def handle_info({type, %BauleBio1.Recipes.Recipe{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :recipes, list_recipes(socket.assigns.current_scope), reset: true)}
  end

  defp list_recipes(current_scope) do
    Recipes.list_recipes(current_scope)
  end
end
