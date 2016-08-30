alias XAdmin.Utils
defprotocol XAdmin.Render do
  # @fallback_to_any true
  def to_string(data)
end

defimpl XAdmin.Render, for: Atom do
  def to_string(nil), do: ""
  def to_string(atom), do: "#{atom}"
end

defimpl XAdmin.Render, for: BitString do
  def to_string(data), do: data
end

defimpl XAdmin.Render, for: Integer do
  def to_string(data), do: Integer.to_string(data)
end

defimpl XAdmin.Render, for: Float do
  def to_string(data), do: Float.to_string(data)
end

defimpl XAdmin.Render, for: Ecto.Time do
  def to_string(dt) do
    dt
    |> Ecto.Time.to_string
    |> String.replace("Z", "")
  end
end

defimpl XAdmin.Render, for: Ecto.DateTime do
  def to_string(dt) do
    dt
    |> Utils.to_datetime
    |> :calendar.universal_time_to_local_time
    |> Utils.format_datetime
  end
end

defimpl XAdmin.Render, for: Ecto.Date do
  def to_string(dt) do
    Ecto.Date.to_string dt
  end
end

defimpl XAdmin.Render, for: Decimal do
  def to_string(decimal) do
    Decimal.to_string decimal
  end
end

defimpl XAdmin.Render, for: Map do
  def to_string(map) do
    Poison.encode! map
  end
end

defimpl XAdmin.Render, for: List do
  def to_string(list) do
    if Enum.all?(list, &(is_integer(&1))) do
      str = List.to_string(list)
      if String.printable? str do
        str
      else
        Poison.encode! list
      end
    else
      Poison.encode! list
    end
  end
end

# defimpl XAdmin.Render, for: Any do
#   def to_string(data), do: "#{inspect data}"
# end
