defmodule Bonfire.UI.Contribution.Repo.Migrations.ImportMe do
  use Ecto.Migration

  import Bonfire.UI.Contribution.Migration
  # accounts & users

  def change, do: migrate_me

end
