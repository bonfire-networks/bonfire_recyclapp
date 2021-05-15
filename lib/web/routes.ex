defmodule Bonfire.Recyclapp.Routes do
  defmacro __using__(_) do

    quote do

      pipeline :recyclapp do
        plug :put_root_layout, {Bonfire.Recyclapp.LayoutView, :root}
      end

      # pages anyone can view
      scope "/bread", Bonfire.Recyclapp do
        pipe_through :browser

      end

      # pages you need an account to view
      scope "/bread", Bonfire.Recyclapp do
        pipe_through :browser
        pipe_through :account_required

      end

      # VF pages you need to view as a user
      scope "/recyclapp", Bonfire.Recyclapp do
        pipe_through :browser
        pipe_through :user_required
        pipe_through :recyclapp

        live "/", RecyclappDashboardLive
        live "/settings", RecyclappSettingsLive
        live "/success/:reciprocal_id", RecyclappSuccessLive

        live "/map/", MapLive
        live "/map/:id", MapLive
      end
    end
  end
end
