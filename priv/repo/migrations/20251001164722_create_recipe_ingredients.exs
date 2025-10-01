defmodule BauleBio1.Repo.Migrations.CreateRecipeIngredients do
  use Ecto.Migration

  def change do
    create table(:recipe_ingredients, primary_key: false) do
      add :recipe_id, references(:recipes, on_delete: :delete_all), primary_key: true
      add :ingredient_id, references(:ingredients, on_delete: :delete_all), primary_key: true
      add :quantity, :string
      add :unit, :string

      timestamps(type: :utc_datetime)
    end

    create index(:recipe_ingredients, [:recipe_id])
    create index(:recipe_ingredients, [:ingredient_id])
  end
end
