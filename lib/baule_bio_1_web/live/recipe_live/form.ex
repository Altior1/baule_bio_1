defmodule BauleBio1Web.RecipeLive.Form do
  use BauleBio1Web, :live_view

  alias BauleBio1.Recipes
  alias BauleBio1.Recipes.Recipe

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-2xl mx-auto">
        <.header>
          {@page_title}
          <:subtitle>
            <%= if @live_action == :new do %>
              Créez une nouvelle recette biologique à partager avec la communauté.
            <% else %>
              Modifiez votre recette biologique.
            <% end %>
          </:subtitle>
        </.header>

        <div class="bg-white shadow-sm rounded-lg border">
          <.form for={@form} id="recipe-form" phx-change="validate" phx-submit="save" class="space-y-6 p-6">
            <!-- Informations de base -->
            <div class="space-y-4">
              <h3 class="text-lg font-medium text-gray-900">Informations générales</h3>
              
              <.input field={@form[:title]} type="text" label="Titre de la recette" required />
              <.input field={@form[:description]} type="textarea" label="Description courte" 
                     placeholder="Décrivez brièvement votre recette..." rows="3" />
            </div>

            <!-- Instructions -->
            <div class="space-y-4">
              <h3 class="text-lg font-medium text-gray-900">Préparation</h3>
              
              <.input field={@form[:instructions]} type="textarea" label="Instructions détaillées" 
                     placeholder="Décrivez étape par étape la préparation de votre recette..." rows="8" required />
            </div>

            <!-- Temps et portions -->
            <div class="space-y-4">
              <h3 class="text-lg font-medium text-gray-900">Timing et portions</h3>
              
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <.input field={@form[:prep_time]} type="number" label="Temps de préparation (min)" min="1" required />
                <.input field={@form[:cook_time]} type="number" label="Temps de cuisson (min)" min="0" required />
                <.input field={@form[:servings]} type="number" label="Nombre de portions" min="1" required />
              </div>
            </div>

            <!-- Statut (seulement pour admin ou si edit et draft) -->
            <%= if show_status_field?(@current_scope, @recipe) do %>
              <div class="space-y-4">
                <h3 class="text-lg font-medium text-gray-900">Statut</h3>
                <.input field={@form[:status]} type="select" label="Statut de la recette" 
                       options={status_options(@current_scope)} />
              </div>
            <% end %>

            <!-- Actions -->
            <div class="flex items-center justify-between pt-6 border-t border-gray-200">
              <.link navigate={return_path(@current_scope, @return_to, @recipe)} 
                     class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                <.icon name="hero-arrow-left" class="w-4 h-4 mr-2" />
                Annuler
              </.link>

              <div class="flex gap-3">
                <%= if @live_action == :edit && @recipe.status == "draft" do %>
                  <.button type="button" phx-click="save_as_draft" class="bg-gray-600 hover:bg-gray-700">
                    <.icon name="hero-document" class="w-4 h-4 mr-2" />
                    Enregistrer le brouillon
                  </.button>
                <% end %>
                
                <.button phx-disable-with="Enregistrement..." variant="primary">
                  <.icon name="hero-check" class="w-4 h-4 mr-2" />
                  <%= if @live_action == :new do %>
                    Soumettre pour validation
                  <% else %>
                    Enregistrer les modifications
                  <% end %>
                </.button>
              </div>
            </div>
          </.form>
        </div>

        <!-- Aide -->
        <div class="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div class="flex">
            <.icon name="hero-information-circle" class="w-5 h-5 text-blue-600 mt-0.5 mr-3" />
            <div class="text-sm text-blue-700">
              <p class="font-medium mb-1">Conseils pour une bonne recette :</p>
              <ul class="list-disc list-inside space-y-1 text-blue-600">
                <li>Utilisez des ingrédients biologiques et de saison</li>
                <li>Décrivez clairement chaque étape de préparation</li>
                <li>Indiquez les temps de préparation et de cuisson précisément</li>
                <li>Votre recette sera vérifiée par nos experts avant publication</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
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
    recipe = Recipes.get_recipe!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Recipe")
    |> assign(:recipe, recipe)
    |> assign(:form, to_form(Recipes.change_recipe(socket.assigns.current_scope, recipe)))
  end

  defp apply_action(socket, :new, _params) do
    recipe = %Recipe{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Recipe")
    |> assign(:recipe, recipe)
    |> assign(:form, to_form(Recipes.change_recipe(socket.assigns.current_scope, recipe)))
  end

  @impl true
  def handle_event("validate", %{"recipe" => recipe_params}, socket) do
    changeset = Recipes.change_recipe(socket.assigns.current_scope, socket.assigns.recipe, recipe_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"recipe" => recipe_params}, socket) do
    save_recipe(socket, socket.assigns.live_action, recipe_params)
  end

  def handle_event("save_as_draft", _params, socket) do
    form_params = 
      socket.assigns.form.params
      |> Map.put("status", "draft")
    
    save_recipe(socket, socket.assigns.live_action, form_params)
  end

  defp save_recipe(socket, :edit, recipe_params) do
    case Recipes.update_recipe(socket.assigns.current_scope, socket.assigns.recipe, recipe_params) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, recipe)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_recipe(socket, :new, recipe_params) do
    case Recipes.create_recipe(socket.assigns.current_scope, recipe_params) do
      {:ok, recipe} ->
        {:noreply,
         socket
         |> put_flash(:info, "Recipe created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, recipe)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp show_status_field?(current_scope, recipe) do
    # Seuls les admins peuvent modifier le statut, ou l'utilisateur sur ses brouillons
    current_scope.user.role == "admin" || 
    (recipe.status == "draft" && recipe.user_id == current_scope.user.id)
  end

  defp status_options(current_scope) do
    if current_scope.user.role == "admin" do
      [
        {"Brouillon", "draft"},
        {"En attente", "pending"},
        {"Approuvée", "approved"},
        {"Rejetée", "rejected"}
      ]
    else
      [{"Brouillon", "draft"}]
    end
  end

  defp return_path(_scope, "index", _recipe), do: ~p"/my-recipes"
  defp return_path(_scope, "show", recipe), do: ~p"/recipes/#{recipe}"
end
