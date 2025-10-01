defmodule BauleBio1Web.Admin.IngredientLive.Index do
  use BauleBio1Web, :live_view

  alias BauleBio1.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Ingredients
        <:actions>
          <.button variant="primary" navigate={~p"/admin/ingredients/new"}>
            <.icon name="hero-plus" /> New Ingredient
          </.button>
        </:actions>
      </.header>

      <.table
        id="ingredients"
        rows={@streams.ingredients}
        row_click={fn {_id, ingredient} -> JS.navigate(~p"/admin/ingredients/#{ingredient}") end}
      >
        <:col :let={{_id, ingredient}} label="Name">{ingredient.name}</:col>
        <:col :let={{_id, ingredient}} label="Description">{ingredient.description}</:col>
        <:action :let={{_id, ingredient}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/ingredients/#{ingredient}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/ingredients/#{ingredient}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, ingredient}}>
          <.link
            phx-click={JS.push("delete", value: %{id: ingredient.id}) |> hide("##{id}")}
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
      Catalog.subscribe_ingredients(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Ingredients")
     |> stream(:ingredients, list_ingredients(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    ingredient = Catalog.get_ingredient!(socket.assigns.current_scope, id)
    {:ok, _} = Catalog.delete_ingredient(socket.assigns.current_scope, ingredient)

    {:noreply, stream_delete(socket, :ingredients, ingredient)}
  end

  @impl true
  def handle_info({type, %BauleBio1.Catalog.Ingredient{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :ingredients, list_ingredients(socket.assigns.current_scope), reset: true)}
  end

  defp list_ingredients(current_scope) do
    Catalog.list_ingredients(current_scope)
  end
end
