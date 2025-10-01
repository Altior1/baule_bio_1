# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

import Ecto.Query, warn: false
alias BauleBio1.Repo
alias BauleBio1.Accounts
alias BauleBio1.Catalog
alias BauleBio1.Recipes

# Création d'un utilisateur admin
admin_attrs = %{
  email: "admin@baulbio.com",
  password: "admin123456789",
  role: "admin"
}

admin_user =
  case Accounts.get_user_by_email(admin_attrs.email) do
    nil ->
      {:ok, user} = Accounts.register_user(admin_attrs)
      # Confirmer automatiquement l'admin
      Accounts.User.confirm_changeset(user) |> Repo.update!()

    user ->
      user
  end

IO.puts("Admin user created: #{admin_user.email}")

# Création d'un utilisateur normal
user_attrs = %{
  email: "user@baulbio.com",
  password: "user123456789",
  role: "user"
}

normal_user =
  case Accounts.get_user_by_email(user_attrs.email) do
    nil ->
      {:ok, user} = Accounts.register_user(user_attrs)
      Accounts.User.confirm_changeset(user) |> Repo.update!()

    user ->
      user
  end

IO.puts("Normal user created: #{normal_user.email}")

# Création d'ingrédients de base
ingredients_data = [
  %{
    name: "Farine de blé bio",
    description: "Farine de blé complet issu de l'agriculture biologique"
  },
  %{name: "Œufs bio", description: "Œufs de poules élevées en plein air, agriculture biologique"},
  %{name: "Lait bio", description: "Lait entier de vaches nourries à l'herbe, certifié bio"},
  %{name: "Beurre bio", description: "Beurre doux issu de crème biologique"},
  %{
    name: "Sucre de canne bio",
    description: "Sucre de canne blond non raffiné, commerce équitable"
  },
  %{
    name: "Huile d'olive vierge bio",
    description: "Huile d'olive extra vierge première pression à froid"
  },
  %{
    name: "Tomates bio",
    description: "Tomates fraîches de saison issues de l'agriculture biologique"
  },
  %{name: "Basilic frais bio", description: "Basilic frais cultivé sans pesticides"},
  %{name: "Ail bio", description: "Ail rose de Lautrec certifié agriculture biologique"},
  %{name: "Pâtes bio", description: "Pâtes de blé dur biologiques artisanales"}
]

for ingredient_attrs <- ingredients_data do
  case Repo.get_by(Catalog.Ingredient, name: ingredient_attrs.name) do
    nil ->
      Catalog.Ingredient.changeset(%Catalog.Ingredient{}, ingredient_attrs)
      |> Repo.insert!()

      IO.puts("Ingredient created: #{ingredient_attrs.name}")

    _ingredient ->
      IO.puts("Ingredient already exists: #{ingredient_attrs.name}")
  end
end

# Récupération des ingrédients créés
farine = Repo.get_by!(Catalog.Ingredient, name: "Farine de blé bio")
oeufs = Repo.get_by!(Catalog.Ingredient, name: "Œufs bio")
lait = Repo.get_by!(Catalog.Ingredient, name: "Lait bio")
beurre = Repo.get_by!(Catalog.Ingredient, name: "Beurre bio")
sucre = Repo.get_by!(Catalog.Ingredient, name: "Sucre de canne bio")
tomates = Repo.get_by!(Catalog.Ingredient, name: "Tomates bio")
basilic = Repo.get_by!(Catalog.Ingredient, name: "Basilic frais bio")
ail = Repo.get_by!(Catalog.Ingredient, name: "Ail bio")
huile = Repo.get_by!(Catalog.Ingredient, name: "Huile d'olive vierge bio")
pates = Repo.get_by!(Catalog.Ingredient, name: "Pâtes bio")

# Création d'une recette exemple approuvée
recipe_attrs = %{
  title: "Pâtes aux tomates et basilic bio",
  description: "Une recette simple et savoureuse avec des ingrédients 100% biologiques",
  instructions: """
  1. Faire bouillir une grande casserole d'eau salée
  2. Faire chauffer l'huile d'olive dans une poêle
  3. Ajouter l'ail émincé et faire revenir 1 minute
  4. Ajouter les tomates coupées en dés et laisser mijoter 10 minutes
  5. Cuire les pâtes selon les instructions du paquet
  6. Égoutter les pâtes et les mélanger à la sauce tomate
  7. Ajouter le basilic frais ciselé avant de servir
  8. Servir immédiatement avec un filet d'huile d'olive
  """,
  prep_time: 15,
  cook_time: 20,
  servings: 4,
  status: "approved",
  user_id: normal_user.id
}

case Repo.get_by(Recipes.Recipe, title: recipe_attrs.title) do
  nil ->
    recipe =
      %Recipes.Recipe{}
      |> Ecto.Changeset.cast(recipe_attrs, [
        :title,
        :description,
        :instructions,
        :prep_time,
        :cook_time,
        :servings,
        :status,
        :user_id
      ])
      |> Ecto.Changeset.validate_required([
        :title,
        :description,
        :instructions,
        :prep_time,
        :cook_time,
        :servings,
        :status,
        :user_id
      ])
      |> Repo.insert!()

    IO.puts("Recipe created: #{recipe.title}")

  _recipe ->
    IO.puts("Recipe already exists: #{recipe_attrs.title}")
end

IO.puts("Seeds completed!")
IO.puts("Admin login: admin@baulbio.com / admin123456789")
IO.puts("User login: user@baulbio.com / user123456789")
