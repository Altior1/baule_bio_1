defmodule BauleBio1.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :title, :string
      add :description, :text
      add :instructions, :text
      add :prep_time, :integer
      add :cook_time, :integer
      add :servings, :integer
      add :status, :string, default: "draft"
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:recipes, [:user_id])
    create index(:recipes, [:status])
  end
end
