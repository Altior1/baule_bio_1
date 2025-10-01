defmodule BauleBio1Web.AdminLive.RecipeApproval do
  use BauleBio1Web, :live_view

  alias BauleBio1.Recipes

  @impl true
  def mount(_params, _session, socket) do
    pending_recipes = Recipes.list_pending_recipes()

    {:ok,
     socket
     |> assign(:page_title, "Validation des Recettes")
     |> stream(:pending_recipes, pending_recipes)}
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(socket.assigns.current_scope, id)

    case Recipes.update_recipe_status(recipe, "approved") do
      {:ok, _recipe} ->
        {:noreply,
         socket
         |> stream_delete(:pending_recipes, recipe)
         |> put_flash(:info, "Recette \"#{recipe.title}\" approuvée")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erreur lors de l'approbation")}
    end
  end

  def handle_event("reject", %{"id" => id}, socket) do
    recipe = Recipes.get_recipe!(socket.assigns.current_scope, id)

    case Recipes.update_recipe_status(recipe, "rejected") do
      {:ok, _recipe} ->
        {:noreply,
         socket
         |> stream_delete(:pending_recipes, recipe)
         |> put_flash(:info, "Recette \"#{recipe.title}\" rejetée")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Erreur lors du rejet")}
    end
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

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Gérez les recettes soumises par les utilisateurs</:subtitle>
      </.header>

      <%= if @streams.pending_recipes |> Enum.empty?() do %>
        <div class="text-center py-12">
          <.icon name="hero-check-circle" class="w-12 h-12 text-green-400 mx-auto mb-4" />
          <h3 class="text-lg font-medium text-gray-900 mb-2">Aucune recette en attente</h3>
          <p class="text-gray-500">
            Toutes les recettes soumises ont été traitées !
          </p>
        </div>
      <% else %>
        <div class="space-y-6">
          <div
            :for={{id, recipe} <- @streams.pending_recipes}
            id={id}
            class="bg-white rounded-lg shadow-sm border overflow-hidden"
          >
            <div class="p-6">
              <div class="flex justify-between items-start mb-4">
                <div class="flex-1">
                  <h3 class="text-xl font-semibold text-gray-900 mb-2">{recipe.title}</h3>
                  <p class="text-gray-600 mb-3">{recipe.description}</p>

                  <div class="flex items-center gap-4 text-sm text-gray-500 mb-4">
                    <div class="flex items-center gap-1">
                      <.icon name="hero-user" class="w-4 h-4" />
                      <span>Par {recipe.user.email}</span>
                    </div>
                    <div class="flex items-center gap-1">
                      <.icon name="hero-clock" class="w-4 h-4" />
                      <span>Prep: {format_time(recipe.prep_time)}</span>
                    </div>
                    <div class="flex items-center gap-1">
                      <.icon name="hero-fire" class="w-4 h-4" />
                      <span>Cuisson: {format_time(recipe.cook_time)}</span>
                    </div>
                    <div class="flex items-center gap-1">
                      <.icon name="hero-users" class="w-4 h-4" />
                      <span>{recipe.servings} portions</span>
                    </div>
                  </div>
                </div>

                <div class="ml-6 flex gap-2">
                  <.link
                    navigate={~p"/recipes/#{recipe}"}
                    class="inline-flex items-center px-3 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
                  >
                    <.icon name="hero-eye" class="w-4 h-4 mr-2" /> Voir
                  </.link>

                  <button
                    phx-click="approve"
                    phx-value-id={recipe.id}
                    class="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
                  >
                    <.icon name="hero-check" class="w-4 h-4 mr-2" /> Approuver
                  </button>

                  <button
                    phx-click="reject"
                    phx-value-id={recipe.id}
                    data-confirm="Êtes-vous sûr de vouloir rejeter cette recette ?"
                    class="inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700"
                  >
                    <.icon name="hero-x-mark" class="w-4 h-4 mr-2" /> Rejeter
                  </button>
                </div>
              </div>
              
    <!-- Aperçu des instructions -->
              <div class="border-t pt-4">
                <h4 class="font-medium text-gray-900 mb-2">Instructions :</h4>
                <div class="bg-gray-50 rounded-md p-3">
                  <p class="text-sm text-gray-700 line-clamp-3">
                    {recipe.instructions}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </Layouts.app>
    """
  end
end
