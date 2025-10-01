defmodule BauleBio1Web.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use BauleBio1Web, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <header class="bg-white shadow-sm border-b border-zinc-100">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <!-- Logo et nom de l'app -->
          <div class="flex items-center">
            <.link navigate={~p"/"} class="flex items-center space-x-2">
              <div class="w-8 h-8 bg-emerald-600 rounded-lg flex items-center justify-center">
                <.icon name="hero-beaker" class="w-5 h-5 text-white" />
              </div>
              <span class="text-xl font-bold text-gray-900">Baule Bio</span>
            </.link>
          </div>
          
    <!-- Navigation principale -->
          <nav class="hidden md:flex items-center space-x-8">
            <.link
              navigate={~p"/recipes"}
              class="text-gray-600 hover:text-gray-900 px-3 py-2 text-sm font-medium"
            >
              <.icon name="hero-book-open" class="w-4 h-4 inline mr-1" /> Recettes
            </.link>

            <%= if @current_scope do %>
              <.link
                navigate={~p"/my-recipes"}
                class="text-gray-600 hover:text-gray-900 px-3 py-2 text-sm font-medium"
              >
                <.icon name="hero-heart" class="w-4 h-4 inline mr-1" /> Mes Recettes
              </.link>

              <.link
                navigate={~p"/recipes/new"}
                class="bg-emerald-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-emerald-700"
              >
                <.icon name="hero-plus" class="w-4 h-4 inline mr-1" /> Nouvelle Recette
              </.link>
            <% end %>
          </nav>
          
    <!-- Menu utilisateur -->
          <div class="flex items-center space-x-4">
            <.theme_toggle />

            <%= if @current_scope do %>
              <!-- Menu dropdown pour utilisateur connecté -->
              <div class="relative">
                <button class="flex items-center space-x-2 text-gray-600 hover:text-gray-900 px-3 py-2 text-sm font-medium">
                  <.icon name="hero-user-circle" class="w-5 h-5" />
                  <span>{@current_scope.user.email}</span>
                  <.icon name="hero-chevron-down" class="w-4 h-4" />
                </button>
                
    <!-- Dropdown menu (caché par défaut, à gérer avec JS) -->
                <div
                  class="absolute right-0 mt-2 w-48 bg-white rounded-md shadow-lg py-1 z-50 hidden"
                  id="user-menu"
                >
                  <.link
                    navigate={~p"/users/settings"}
                    class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    <.icon name="hero-cog-6-tooth" class="w-4 h-4 inline mr-2" /> Paramètres
                  </.link>

                  <%= if @current_scope.user.role == "admin" do %>
                    <div class="border-t border-gray-100 py-1">
                      <.link href={~p"/admin/ingredients"} class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                        <.icon name="hero-beaker" class="w-4 h-4 inline mr-2" />
                        Gestion Ingrédients
                      </.link>
                      <.link href={~p"/admin/recipe-approval"} class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">
                        <.icon name="hero-clipboard-document-check" class="w-4 h-4 inline mr-2" />
                        Validation Recettes
                      </.link>
                    </div>
                  <% end %>                  <hr class="my-1" />
                  <.link
                    href={~p"/users/log-out"}
                    method="delete"
                    class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    <.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4 inline mr-2" />
                    Déconnexion
                  </.link>
                </div>
              </div>
            <% else %>
              <!-- Boutons pour utilisateur non connecté -->
              <.link
                navigate={~p"/users/log-in"}
                class="text-gray-600 hover:text-gray-900 px-3 py-2 text-sm font-medium"
              >
                Connexion
              </.link>
              <.link
                navigate={~p"/users/register"}
                class="bg-emerald-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-emerald-700"
              >
                Inscription
              </.link>
            <% end %>
          </div>
          
    <!-- Menu mobile -->
          <div class="md:hidden">
            <button class="text-gray-600 hover:text-gray-900" onclick="toggleMobileMenu()">
              <.icon name="hero-bars-3" class="w-6 h-6" />
            </button>
          </div>
        </div>
        
    <!-- Navigation mobile -->
        <div class="md:hidden hidden" id="mobile-menu">
          <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3 border-t border-gray-200">
            <.link
              navigate={~p"/recipes"}
              class="block px-3 py-2 text-base font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50"
            >
              <.icon name="hero-book-open" class="w-4 h-4 inline mr-2" /> Recettes
            </.link>

            <%= if @current_scope do %>
              <.link
                navigate={~p"/my-recipes"}
                class="block px-3 py-2 text-base font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                <.icon name="hero-heart" class="w-4 h-4 inline mr-2" /> Mes Recettes
              </.link>

              <.link
                navigate={~p"/recipes/new"}
                class="block px-3 py-2 text-base font-medium text-emerald-600 hover:text-emerald-700 hover:bg-gray-50"
              >
                <.icon name="hero-plus" class="w-4 h-4 inline mr-2" /> Nouvelle Recette
              </.link>

              <%= if @current_scope.user.role == "admin" do %>
                <div class="border-t border-gray-200 pt-2 mt-2">
                  <div class="px-3 py-2 text-xs font-medium text-gray-500 uppercase tracking-wide">
                    Administration
                  </div>
                  <.link
                    navigate={~p"/admin/ingredients"}
                    class="block px-3 py-2 text-base font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50"
                  >
                    <.icon name="hero-beaker" class="w-4 h-4 inline mr-2" /> Ingrédients
                  </.link>
                  <.link
                    navigate={~p"/admin/recipes/pending"}
                    class="block px-3 py-2 text-base font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50"
                  >
                    <.icon name="hero-clipboard-document-check" class="w-4 h-4 inline mr-2" />
                    Recettes à approuver
                  </.link>
                </div>
              <% end %>
            <% else %>
              <.link
                navigate={~p"/users/log-in"}
                class="block px-3 py-2 text-base font-medium text-gray-600 hover:text-gray-900 hover:bg-gray-50"
              >
                Connexion
              </.link>
              <.link
                navigate={~p"/users/register"}
                class="block px-3 py-2 text-base font-medium text-emerald-600 hover:text-emerald-700 hover:bg-gray-50"
              >
                Inscription
              </.link>
            <% end %>
          </div>
        </div>
      </div>
    </header>

    <main class="min-h-screen bg-gray-50">
      <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        {render_slot(@inner_block)}
      </div>
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
