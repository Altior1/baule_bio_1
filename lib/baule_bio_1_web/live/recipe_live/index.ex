defmodule BauleBio1Web.RecipeLive.Index do
  use BauleBio1Web, :live_view

  alias BauleBio1.Recipes

  @impl true
  def mount(_params, _session, socket) do
    recipes =
      case socket.assigns.live_action do
        :index -> Recipes.list_approved_recipes()
        :my_recipes -> Recipes.list_user_recipes(socket.assigns.current_scope)
      end

    page_title =
      case socket.assigns.live_action do
        :index -> "Recettes Biologiques"
        :my_recipes -> "Mes Recettes"
      end

    {:ok,
     socket
     |> assign(:page_title, page_title)
     |> stream(:recipes, recipes)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(socket.assigns.current_scope, id)
    {:ok, _} = Recipes.delete_recipe(socket.assigns.current_scope, recipe)

    {:noreply, stream_delete(socket, :recipes, recipe)}
  end

  defp status_variant("approved"), do: "bg-green-100 text-green-800"
  defp status_variant("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_variant("rejected"), do: "bg-red-100 text-red-800"
  defp status_variant("draft"), do: "bg-gray-100 text-gray-800"

  defp status_text("approved"), do: "Approuvée"
  defp status_text("pending"), do: "En attente"
  defp status_text("rejected"), do: "Rejetée"
  defp status_text("draft"), do: "Brouillon"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:actions>
          <%= if @current_scope && @live_action != :index do %>
            <.button variant="primary" navigate={~p"/recipes/new"}>
              <.icon name="hero-plus" /> Nouvelle Recette
            </.button>
          <% end %>
        </:actions>
      </.header>

      <%= if @live_action == :index do %>
        <!-- Vue publique des recettes approuvées -->
        <div class="mb-8">
          <p class="text-gray-600">
            Découvrez nos recettes biologiques approuvées par nos experts culinaires.
          </p>
        </div>

        <%= if @streams.recipes |> Enum.empty?() do %>
          <div class="text-center py-12">
            <.icon name="hero-book-open" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune recette disponible</h3>
            <p class="text-gray-500 mb-6">
              Soyez le premier à partager une délicieuse recette bio !
            </p>
            <%= if @current_scope do %>
              <.button navigate={~p"/recipes/new"} variant="primary">
                <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Créer ma première recette
              </.button>
            <% else %>
              <.button navigate={~p"/users/register"} variant="primary">
                Rejoindre la communauté
              </.button>
            <% end %>
          </div>
        <% else %>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <div
              :for={{_id, recipe} <- @streams.recipes}
              class="bg-white rounded-lg shadow-sm border hover:shadow-md transition-shadow"
            >
              <div class="p-6">
                <h3 class="text-lg font-semibold text-gray-900 mb-2">{recipe.title}</h3>
                <p class="text-gray-600 text-sm mb-4 line-clamp-2">{recipe.description}</p>

                <div class="flex items-center gap-4 text-sm text-gray-500 mb-4">
                  <div class="flex items-center gap-1">
                    <.icon name="hero-clock" class="w-4 h-4" />
                    <span>{recipe.prep_time + recipe.cook_time} min</span>
                  </div>
                  <div class="flex items-center gap-1">
                    <.icon name="hero-users" class="w-4 h-4" />
                    <span>{recipe.servings} pers.</span>
                  </div>
                </div>

                <.link
                  navigate={~p"/recipes/#{recipe}"}
                  class="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 w-full"
                >
                  Voir la recette
                </.link>
              </div>
            </div>
          </div>
        <% end %>
      <% else %>
        <!-- Vue "Mes Recettes" -->
        <%= if @streams.recipes |> Enum.empty?() do %>
          <div class="text-center py-12">
            <.icon name="hero-heart" class="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune recette créée</h3>
            <p class="text-gray-500 mb-6">
              Commencez à partager vos délicieuses recettes biologiques !
            </p>
            <.button navigate={~p"/recipes/new"} variant="primary">
              <.icon name="hero-plus" class="w-4 h-4 mr-2" /> Créer ma première recette
            </.button>
          </div>
        <% else %>
          <.table
            id="recipes"
            rows={@streams.recipes}
            row_click={fn {_id, recipe} -> JS.navigate(~p"/recipes/#{recipe}") end}
          >
            <:col :let={{_id, recipe}} label="Titre">{recipe.title}</:col>
            <:col :let={{_id, recipe}} label="Temps (min)">
              <div class="flex items-center gap-2">
                <span class="text-xs bg-gray-100 px-2 py-1 rounded">Prep: {recipe.prep_time}</span>
                <span class="text-xs bg-gray-100 px-2 py-1 rounded">Cuisson: {recipe.cook_time}</span>
              </div>
            </:col>
            <:col :let={{_id, recipe}} label="Portions">{recipe.servings}</:col>
            <:col :let={{_id, recipe}} label="Statut">
              <span class={[
                "inline-flex items-center px-2 py-1 rounded-full text-xs font-medium",
                status_variant(recipe.status)
              ]}>
                {status_text(recipe.status)}
              </span>
            </:col>
            <:action :let={{_id, recipe}}>
              <div class="sr-only">
                <.link navigate={~p"/recipes/#{recipe}"}>Voir</.link>
              </div>
              <.link
                navigate={~p"/recipes/#{recipe}/edit"}
                class="text-indigo-600 hover:text-indigo-900"
              >
                Modifier
              </.link>
            </:action>
            <:action :let={{id, recipe}}>
              <.link
                phx-click={JS.push("delete", value: %{id: recipe.id}) |> hide("##{id}")}
                data-confirm="Êtes-vous sûr de vouloir supprimer cette recette ?"
                class="text-red-600 hover:text-red-900"
              >
                Supprimer
              </.link>
            </:action>
          </.table>
        <% end %>
      <% end %>
    </Layouts.app>
    """
  end
end
