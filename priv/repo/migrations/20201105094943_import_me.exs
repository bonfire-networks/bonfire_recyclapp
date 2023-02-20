defmodule Bonfire.Recyclapp.Repo.Migrations.ImportMe  do
  @moduledoc false
  use Ecto.Migration

  import Bonfire.Recyclapp.Migration
  # accounts & users

  def change, do: migrate_me
end
