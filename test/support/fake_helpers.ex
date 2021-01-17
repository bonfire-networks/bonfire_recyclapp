defmodule Bonfire.UI.Contribution.Test.FakeHelpers do

  alias Bonfire.Data.Identity.Account
  alias Bonfire.UI.Contribution.Fake
  alias Bonfire.UI.Contribution.Identity.{Accounts, Users}
  import ExUnit.Assertions

  import Bonfire.UI.Contribution.Integration

  def fake_account!(attrs \\ %{}) do
    cs = Accounts.signup_changeset(Fake.account(attrs))
    assert {:ok, account} = repo().insert(cs)
    account
  end

  def fake_user!(%Account{}=account, attrs \\ %{}) do
    assert {:ok, user} = Users.create(Fake.user(attrs), account)
    user
  end

end
