defmodule BauleBio1Web.Admin.IngredientLive.Form do
  use BauleBio1Web, :live_view

  alias BauleBio1.Catalog
  alias BauleBio1.Catalog.Ingredient

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage ingredient records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="ingredient-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Ingredient</.button>
          <.button navigate={return_path(@current_scope, @return_to, @ingredient)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    ingredient = Catalog.get_ingredient!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Ingredient")
    |> assign(:ingredient, ingredient)
    |> assign(:form, to_form(Catalog.change_ingredient(ingredient)))
  end

  defp apply_action(socket, :new, _params) do
    ingredient = %Ingredient{}

    socket
    |> assign(:page_title, "New Ingredient")
    |> assign(:ingredient, ingredient)
    |> assign(:form, to_form(Catalog.change_ingredient(ingredient)))
  end

  @impl true
  def handle_event("validate", %{"ingredient" => ingredient_params}, socket) do
    changeset = Catalog.change_ingredient(socket.assigns.ingredient, ingredient_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"ingredient" => ingredient_params}, socket) do
    save_ingredient(socket, socket.assigns.live_action, ingredient_params)
  end

  defp save_ingredient(socket, :edit, ingredient_params) do
    case Catalog.update_ingredient(
           socket.assigns.current_scope,
           socket.assigns.ingredient,
           ingredient_params
         ) do
      {:ok, ingredient} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ingredient updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, ingredient)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_ingredient(socket, :new, ingredient_params) do
    case Catalog.create_ingredient(socket.assigns.current_scope, ingredient_params) do
      {:ok, ingredient} ->
        {:noreply,
         socket
         |> put_flash(:info, "Ingredient created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, ingredient)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _ingredient), do: ~p"/admin/ingredients"
  defp return_path(_scope, "show", ingredient), do: ~p"/admin/ingredients/#{ingredient}"
end
