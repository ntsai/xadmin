defprotocol XAdmin.Authentication do
  @fallback_to_any true
  def use_authentication?(conn)
  def current_user(conn)
  def current_user_name(conn)
  def session_path(conn, action)
end

defimpl XAdmin.Authentication, for: Any do
  def use_authentication?(_), do: false
  def current_user(_), do: nil
  def current_user_name(_), do: nil
  def session_path(_, _), do: ""
end

defprotocol XAdmin.Authorization do
  @fallback_to_any true
  def authorize_query(defn, conn, query, action, id)
  def authorize_action(defn, conn, action)
end

defimpl XAdmin.Authorization, for: Any do
  def authorize_query(_, _, query, _, _), do: query
  def authorize_action(_, _, _), do: true
end

