defmodule BauleBio1.Repo.Migrations.RemoveUserIdFromIngredients do
  use Ecto.Migration

  def change do
    alter table(:ingredients) do
      remove :user_id, references(:users)
    end
  end
end
