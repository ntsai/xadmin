defmodule TestXAdmin.Repo do
  use Ecto.Repo,  otp_app: :xadmin
  use Scrivener, page_size: 10
end
