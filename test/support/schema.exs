defmodule TestXAdmin.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :active, :boolean, default: true
    has_many :products, TestXAdmin.Product
    has_many :noids, TestXAdmin.Noid
    has_many :uses_roles, TestXAdmin.UserRole
    has_many :roles, through: [:uses_roles, :user]
  end

  @required_fields ~w(email)
  @optional_fields ~w(name active)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
defmodule TestXAdmin.Role do
  use Ecto.Schema
  import Ecto.Changeset
  alias TestXAdmin.Repo

  schema "roles" do
    field :name, :string
    has_many :uses_roles, TestXAdmin.UserRole
    has_many :roles, through: [:uses_roles, :role]
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def all do
    Repo.all __MODULE__
  end
end

defmodule TestXAdmin.UserRole do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users_roles" do
    belongs_to :user, TestXAdmin.User
    belongs_to :role, TestXAdmin.Role

    timestamps
  end

  @required_fields ~w(user_id role_id)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :title, :string
    field :price, :decimal
    belongs_to :user, TestXAdmin.User
  end

  @required_fields ~w(title price)
  @optional_fields ~w(user_id)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.Noid do
  import Ecto.Changeset
  use Ecto.Schema
  @primary_key {:name, :string, []}
  # @derive {Phoenix.Param, key: :name}
  schema "noids" do
    field :description, :string
    field :company, :string
    belongs_to :user, TestXAdmin.User, foreign_key: :user_id, references: :id

  end

  @required_fields ~w(name description)
  @optional_fields ~w(company user_id)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.Noprimary do
  import Ecto.Changeset
  use Ecto.Schema
  @primary_key false
  schema "noprimarys" do
    field :index, :integer
    field :name, :string
    field :description, :string
    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(index description)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.Simple do
  import Ecto.Changeset
  use Ecto.Schema

  schema "simples" do
    field :name, :string
    field :description, :string

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(description)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end

defmodule TestXAdmin.Restricted do
  import Ecto.Changeset
  use Ecto.Schema

  schema "restricteds" do
    field :name, :string
    field :description, :string

  end

  @required_fields ~w(name)
  @optional_fields ~w(description)

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.PhoneNumber do
  import Ecto.Changeset
  use Ecto.Schema
  import Ecto.Query
  alias __MODULE__
  alias TestXAdmin.Repo

  schema "phone_numbers" do
    field :number, :string
    field :label, :string
    has_many :contacts_phone_numbers, TestXAdmin.ContactPhoneNumber
    has_many :contacts, through: [:contacts_phone_numbers, :contact]
    timestamps
  end

  @required_fields ~w(number label)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def labels, do: ["Primary Phone", "Secondary Phone", "Home Phone",
                   "Work Phone", "Mobile Phone", "Other Phone"]

  def all_labels do
    (from p in PhoneNumber, group_by: p.label, select: p.label)
    |> Repo.all
  end
end

defmodule TestXAdmin.Contact do
  import Ecto.Changeset
  use Ecto.Schema

  schema "contacts" do
    field :first_name, :string
    field :last_name, :string
    has_many :contacts_phone_numbers, TestXAdmin.ContactPhoneNumber
    has_many :phone_numbers, through: [:contacts_phone_numbers, :phone_number]
    timestamps
  end

  @required_fields ~w(first_name last_name)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.ContactPhoneNumber do
  import Ecto.Changeset
  use Ecto.Schema

  schema "contacts_phone_numbers" do
    belongs_to :contact, TestXAdmin.Contact
    belongs_to :phone_number, TestXAdmin.PhoneNumber
  end

  @required_fields ~w(contact_id phone_number_id)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end

defmodule TestXAdmin.UUIDSchema do
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:key, :binary_id, autogenerate: true}

  schema "uuid_schemas" do
    field :name, :string
    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w()

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end

defmodule TestXAdmin.ModelDisplayName do
  import Ecto.Changeset
  use Ecto.Schema

  schema "model_display_name" do
    field :first, :string
    field :name, :string
    field :other, :string
  end

  @required_fields ~w(name)
  @optional_fields ~w(first other)

  def display_name(resource) do
    resource.other
  end
end

defmodule TestXAdmin.DefnDisplayName do
  import Ecto.Changeset
  use Ecto.Schema

  schema "defn_display_name" do
    field :first, :string
    field :second, :string
    field :name, :string
  end

  @required_fields ~w(name)
  @optional_fields ~w(first second)

end
