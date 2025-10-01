defmodule BauleBio1Web.Admin.IngredientLive.Show do
  use BauleBio1Web, :live_view

  alias BauleBio1.Catalog

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Ingredient {@ingredient.id}
        <:subtitle>This is a ingredient record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/ingredients"}>
            <.icon name="hero-chevron-left" /> Back to ingredients
          </.button>
        </:actions>
        <:actions>
          <.button
            variant="primary"
            navigate={~p"/admin/ingredients/#{@ingredient}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit ingredient
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@ingredient.name}</:item>
        <:item title="Description">{@ingredient.description}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Catalog.subscribe_ingredients(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Ingredient")
     |> assign(:ingredient, Catalog.get_ingredient!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %BauleBio1.Catalog.Ingredient{id: id} = ingredient},
        %{assigns: %{ingredient: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :ingredient, ingredient)}
  end

  def handle_info(
        {:deleted, %BauleBio1.Catalog.Ingredient{id: id}},
        %{assigns: %{ingredient: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current ingredient was deleted.")
     |> push_navigate(to: ~p"/admin/ingredients")}
  end

  def handle_info({type, %BauleBio1.Catalog.Ingredient{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
