defmodule BauleBio1Web.RecipeLive.Show do
  use BauleBio1Web, :live_view

  alias BauleBio1.Recipes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Recipe {@recipe.id}
        <:subtitle>This is a recipe record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/recipes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/recipes/#{@recipe}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit recipe
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@recipe.title}</:item>
        <:item title="Description">{@recipe.description}</:item>
        <:item title="Instructions">{@recipe.instructions}</:item>
        <:item title="Prep time">{@recipe.prep_time}</:item>
        <:item title="Cook time">{@recipe.cook_time}</:item>
        <:item title="Servings">{@recipe.servings}</:item>
        <:item title="Status">{@recipe.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Recipes.subscribe_recipes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Recipe")
     |> assign(:recipe, Recipes.get_recipe!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %BauleBio1.Recipes.Recipe{id: id} = recipe},
        %{assigns: %{recipe: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :recipe, recipe)}
  end

  def handle_info(
        {:deleted, %BauleBio1.Recipes.Recipe{id: id}},
        %{assigns: %{recipe: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current recipe was deleted.")
     |> push_navigate(to: ~p"/recipes")}
  end

  def handle_info({type, %BauleBio1.Recipes.Recipe{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
