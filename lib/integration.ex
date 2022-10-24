defmodule Bonfire.Recyclapp.Integration do
  def repo, do: Bonfire.Common.Config.repo()

  def mailer, do: Bonfire.Common.Config.get!(:mailer_module)
end
