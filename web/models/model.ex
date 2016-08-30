defmodule XAdmin.Model do
  import Ecto.Query
  import XAdmin.Repo, only: [repo: 0]

  def potential_associations_query(resource, assoc_defn_model, assoc_name, keywords \\ "") do
    current_assoc_ids = resource
    |> repo.preload(assoc_name)
    |> Map.get(assoc_name)
    |> Enum.map(&XAdmin.Schema.get_id/1)

    search_query = assoc_defn_model.build_admin_search_query(keywords)
    (from r in search_query, where: not(r.id in ^current_assoc_ids))
  end
end
