defmodule CaseManager.Places do
  import Ecto.Query, warn: false
  alias CaseManager.Repo

  alias CaseManager.Places.Place

  @doc """
  Returns the list of places.

  ## Examples

      iex> list_places()
      [%Place{}, ...]

  """
  def list_places do
    Repo.all(Place)
  end

  @doc """
  Gets a single place.

  Raises `Ecto.NoResultsError` if the Place does not exist.

  ## Examples

      iex> get_place!(3)
      %Place{}

      iex> get_place!(4235435)
      ** (Ecto.NoResultsError)

  """
  def get_place!(id), do: Repo.get!(Place, id)

  @doc """
  Creates a place.

  ## Examples

      iex> create_place(%{field: value})
      {:ok, %Place{}}

      iex> create_place(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_place(attrs \\ %{}) do
    %Place{}
    |> Place.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a place.

  ## Examples

      iex> update_place(place, %{field: new_value})
      {:ok, %Place{}}

      iex> update_place(place, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_place(%Place{} = place, attrs) do
    place
    |> Place.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a place.

  ## Examples

      iex> delete_place(place)
      {:ok, %Place{}}

      iex> delete_place(place)
      {:error, %Ecto.Changeset{}}

  """
  def delete_place(%Place{} = place) do
    Repo.delete(place)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking place changes.

  ## Examples

      iex> change_place(place)
      %Ecto.Changeset{data: %Place{}}

  """
  def change_place(%Place{} = place, attrs \\ %{}) do
    Place.changeset(place, attrs)
  end

  @doc """
  Returns a list of place options for select inputs based on the given type,
  grouped by country.

  ## Examples

      iex> get_options_for_select(:arrival)
      [
        Italy: ["Palermo", ...],
        Malta: ["Malta", ...],
        ...
      ]

  """
  def get_places_for_select(type) do
    list_places()
    |> Enum.filter(&(&1.type in [type, :both]))
    |> Enum.group_by(& &1.country, &{&1.name, &1.id})
    |> Map.to_list()
  end

  def valid_departure_regions,
    do: [
      :unknown,
      "Libya",
      "Tunisia",
      "Lebanon",
      "Turkey",
      "Syria",
      "Egypt"
    ]
end
