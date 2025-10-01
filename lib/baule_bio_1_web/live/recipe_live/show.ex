defmodule BauleBio1Web.RecipeLive.Show do
  use BauleBio1Web, :live_view

  alias BauleBio1.Recipes

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    recipe = if socket.assigns.current_scope do
      # Utilisateur connecté - peut voir ses propres recettes ou recettes approuvées
      case Recipes.get_recipe(socket.assigns.current_scope, id) do
        nil -> Recipes.get_approved_recipe!(id)
        recipe -> recipe
      end
    else
      # Utilisateur non connecté - seulement les recettes approuvées
      Recipes.get_approved_recipe!(id)
    end

    {:ok,
     socket
     |> assign(:page_title, recipe.title)
     |> assign(:recipe, recipe)}
  end

  @impl true
  def handle_event("approve_recipe", _params, socket) do
    case Recipes.update_recipe_status(socket.assigns.recipe, "approved") do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> assign(:recipe, recipe)
         |> put_flash(:info, "Recette approuvée avec succès")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erreur lors de l'approbation")}
    end
  end

  def handle_event("reject_recipe", _params, socket) do
    case Recipes.update_recipe_status(socket.assigns.recipe, "rejected") do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> assign(:recipe, recipe)
         |> put_flash(:info, "Recette rejetée")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erreur lors du rejet")}
    end
  end

  defp can_edit?(current_scope, recipe) do
    current_scope && 
    (current_scope.user.id == recipe.user_id || current_scope.user.role == "admin")
  end

  defp show_status?(current_scope, recipe) do
    current_scope && 
    (current_scope.user.id == recipe.user_id || current_scope.user.role == "admin")
  end

  defp format_time(minutes) do
    cond do
      minutes >= 60 ->
        hours = div(minutes, 60)
        remaining = rem(minutes, 60)
        if remaining > 0 do
          "#{hours}h #{remaining}min"
        else
          "#{hours}h"
        end
      true ->
        "#{minutes}min"
    end
  end

  defp status_variant("approved"), do: "bg-green-100 text-green-800"
  defp status_variant("pending"), do: "bg-yellow-100 text-yellow-800"
  defp status_variant("rejected"), do: "bg-red-100 text-red-800"
  defp status_variant("draft"), do: "bg-gray-100 text-gray-800"

  defp status_text("approved"), do: "Approuvée"
  defp status_text("pending"), do: "En attente"
  defp status_text("rejected"), do: "Rejetée"
  defp status_text("draft"), do: "Brouillon"

  defp recipe_index_path(nil), do: ~p"/recipes"
  defp recipe_index_path(_current_scope), do: ~p"/my-recipes"

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-4xl mx-auto">
        <!-- Header avec image et informations principales -->
        <div class="bg-white rounded-lg shadow-sm border overflow-hidden mb-8">
          <div class="px-6 py-8">
            <div class="flex justify-between items-start mb-6">
              <div class="flex-1">
                <h1 class="text-3xl font-bold text-gray-900 mb-2">{@recipe.title}</h1>
                <p class="text-lg text-gray-600 mb-4">{@recipe.description}</p>
                
                <!-- Métadonnées -->
                <div class="flex items-center gap-6 text-sm text-gray-500">
                  <div class="flex items-center gap-2">
                    <.icon name="hero-clock" class="w-5 h-5" />
                    <span>Préparation: {format_time(@recipe.prep_time)}</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <.icon name="hero-fire" class="w-5 h-5" />
                    <span>Cuisson: {format_time(@recipe.cook_time)}</span>
                  </div>
                  <div class="flex items-center gap-2">
                    <.icon name="hero-users" class="w-5 h-5" />
                    <span>{@recipe.servings} portions</span>
                  </div>
                </div>

                <!-- Statut si visible pour l'utilisateur -->
                <%= if show_status?(@current_scope, @recipe) do %>
                  <div class="mt-4">
                    <span class={[
                      "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium",
                      status_variant(@recipe.status)
                    ]}>
                      {status_text(@recipe.status)}
                    </span>
                  </div>
                <% end %>
              </div>

              <!-- Actions -->
              <div class="ml-6 flex flex-col gap-2">
                <%= if can_edit?(@current_scope, @recipe) do %>
                  <.link navigate={~p"/recipes/#{@recipe}/edit"} class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700">
                    <.icon name="hero-pencil-square" class="w-4 h-4 mr-2" />
                    Modifier
                  </.link>
                <% end %>
                
                <%= if @current_scope && @current_scope.user.role == "admin" && @recipe.status == "pending" do %>
                  <button phx-click="approve_recipe" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700">
                    <.icon name="hero-check" class="w-4 h-4 mr-2" />
                    Approuver
                  </button>
                  <button phx-click="reject_recipe" class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700">
                    <.icon name="hero-x-mark" class="w-4 h-4 mr-2" />
                    Rejeter
                  </button>
                <% end %>
              </div>
            </div>
          </div>
        </div>

        <!-- Instructions -->
        <div class="bg-white rounded-lg shadow-sm border p-6 mb-8">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Instructions</h2>
          <div class="prose prose-gray max-w-none">
            <div class="whitespace-pre-wrap text-gray-700 leading-relaxed">
              {@recipe.instructions}
            </div>
          </div>
        </div>

        <!-- Ingrédients (si on en a) -->
        <%= if @recipe.recipe_ingredients != [] do %>
          <div class="bg-white rounded-lg shadow-sm border p-6 mb-8">
            <h2 class="text-xl font-semibold text-gray-900 mb-4">Ingrédients</h2>
            <ul class="space-y-2">
              <li :for={recipe_ingredient <- @recipe.recipe_ingredients} class="flex items-center gap-3">
                <div class="w-2 h-2 bg-green-500 rounded-full"></div>
                <span class="font-medium">{recipe_ingredient.quantity} {recipe_ingredient.unit}</span>
                <span class="text-gray-700">{recipe_ingredient.ingredient.name}</span>
              </li>
            </ul>
          </div>
        <% end %>

        <!-- Navigation -->
        <div class="flex justify-between items-center">
          <.link navigate={recipe_index_path(@current_scope)} class="text-indigo-600 hover:text-indigo-800 flex items-center gap-2">
            <.icon name="hero-arrow-left" class="w-4 h-4" />
            Retour aux recettes
          </.link>

          <%= if @current_scope && can_edit?(@current_scope, @recipe) do %>
            <.link navigate={~p"/my-recipes"} class="text-gray-600 hover:text-gray-800">
              Mes recettes
            </.link>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
