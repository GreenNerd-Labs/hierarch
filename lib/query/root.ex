defmodule Hierarch.Query.Root do
  import Ecto.Query

  @doc """
  Return query expressions for the root
  """
  def query(%schema{} = struct) do
    path = Hierarch.Util.struct_path(struct)

    [{pk_column, value}] = Ecto.primary_key(struct)

    root_id = Hierarch.LTree.root_id(path, value)

    from(
      t in schema,
      where: field(t, ^pk_column) == ^root_id
    )
  end
end
