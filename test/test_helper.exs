defmodule Hierarch.TestCase do
  use ExUnit.CaseTemplate

  using(opts) do
    quote do
      use ExUnit.Case, unquote(opts)
      import unquote(__MODULE__), only: [assert_match: 2]
      alias Dummy.{Repo, Catelog, Organization}

      def create_catelogs do
        catelogs_list = [
          "Top",
          "Top.Science",
          "Top.Science.Astronomy",
          "Top.Science.Astronomy.Astrophysics",
          "Top.Science.Astronomy.Cosmology",
          "Top.Hobbies",
          "Top.Hobbies.Amateurs_Astronomy",
          "Top.Collections",
          "Top.Collections.Pictures",
          "Top.Collections.Pictures.Astronomy",
          "Top.Collections.Pictures.Astronomy.Stars",
          "Top.Collections.Pictures.Astronomy.Galaxies",
          "Top.Collections.Pictures.Astronomy.Astronauts"
        ]

        Enum.reduce(catelogs_list, %{}, fn name, acc ->
          parent_name = Hierarch.LTree.parent_path(name)
          parent = Map.get(acc, parent_name)

          catelog =
            case parent do
              nil -> Catelog.build(%{name: name}) |> Repo.insert!()
              _ -> Catelog.build_child_of(parent, %{name: name}) |> Repo.insert!()
            end

          Map.put(acc, name, catelog)
        end)
      end

      def create_organizations do
        organizations_list = [
          "A",
          "A.B",
          "A.B.C",
          "A.D"
        ]

        Enum.reduce(organizations_list, %{}, fn name, acc ->
          parent_name = Hierarch.LTree.parent_path(name)
          parent = Map.get(acc, parent_name)

          organization =
            case parent do
              nil -> Organization.build(%{name: name}) |> Repo.insert!()
              _ -> Organization.build_child_of(parent, %{name: name}) |> Repo.insert!()
            end

          Map.put(acc, name, organization)
        end)
      end
    end
  end

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Dummy.Repo, {:shared, self()})
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Dummy.Repo)
  end

  @doc """
  ## Example

  ```
  assert_match [1, 2], [2, 1]
  ```
  """
  @spec assert_match(list(), list()) :: term()
  defmacro assert_match(list, another_list) do
    quote location: :keep do
      set = MapSet.new(unquote(list))
      another_list = MapSet.new(unquote(another_list))

      assert set == another_list
    end
  end
end

{:ok, _} = Dummy.Repo.start_link()
ExUnit.start()
