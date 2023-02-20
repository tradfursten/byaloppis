defmodule Byaloppis.Repo do
  use Ecto.Repo,
    otp_app: :byaloppis,
    adapter: Ecto.Adapters.SQLite3
end
