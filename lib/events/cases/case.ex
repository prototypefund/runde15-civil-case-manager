defmodule Events.Cases.Case do
  use Ecto.Schema
  import Ecto.Changeset
  import Events.ChangesetValidators


  @derive {
    Flop.Schema,
    filterable: [:status, :name],
    sortable: [:name, :created_at],
    default_order: %{
      order_by: [:created_at],
      order_directions: [:desc, :asc]
    }
  }

  ## TODO Investigate id generation
  @primary_key {:id, :string, autogenerate: false}
  schema "cases" do
    ## Base data
    field :name, :string
    field :notes, :string
    field :status, :string
    field :created_at, :utc_datetime
    field :occurred_at, :utc_datetime

    ## Depature
    field :departure_region, :string
    field :place_of_departure, :string
    field :time_of_departure, :utc_datetime
    field :sar_region, :string

    ## Involved parties
    field :phonenumber, :string
    field :alarmphone_contact , :string
    field :confirmation_by, :string
    field :actors_involved, :string
    field :authorities_alerted, :boolean
    field :authorities_details , :string

    ## The boat
    field :boat_type, :string
    field :boat_notes, :string
    field :boat_color, :string
    field :boat_engine_status, :string
    field :boat_engine_working, :string
    field :boat_number_of_engines, :integer

    ## People on Board
    field :pob_total, :integer
    field :pob_men, :integer
    field :pob_women, :integer
    field :pob_minors, :integer
    field :pob_gender_ambiguous, :integer
    field :pob_medical_cases, :integer
    field :people_dead, :integer
    field :people_missing, :integer
    field :pob_per_nationality, :string

    ## Outcome
    field :outcome, :string
    field :time_of_disembarkation, :utc_datetime
    field :place_of_disembarkation , :string
    field :disembarked_by, :string
    field :outcome_actors, :string
    field :frontext_involvement, :string
    field :followup_needed, :boolean

    ## Meta
    field :template, :string
    field :url, :string
    field :cloud_file_links, :string
    field :imported_from, :string

    many_to_many :events, Events.Eventlog.Event, join_through: Events.CasesEvents

    timestamps(type: :utc_datetime)
  end

  @spec changeset(
          {map(), map()}
          | %{
              :__struct__ => atom() | %{:__changeset__ => map(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(case, attrs) do
    case
    |> cast(attrs, [
      :notes, :name, :status, :created_at, :occurred_at, :departure_region, :place_of_departure, :time_of_departure, :sar_region, :phonenumber, :alarmphone_contact, :confirmation_by, :actors_involved, :authorities_alerted, :authorities_details, :boat_type, :boat_notes, :boat_color, :boat_engine_status, :boat_engine_working, :boat_number_of_engines, :pob_total, :pob_men, :pob_women, :pob_minors, :pob_gender_ambiguous, :pob_medical_cases, :people_dead, :people_missing, :pob_per_nationality, :outcome, :time_of_disembarkation, :place_of_disembarkation, :disembarked_by, :outcome_actors, :frontext_involvement, :followup_needed, :url, :cloud_file_links,
      ])
    |> validate_required([:name, :status])
    #|> validate_number(:course_over_ground, greater_than_or_equal_to: 0, less_than_or_equal_to: 360)
    |> validate_format(
      :name,
     ~r/^[a-zA-Z0-9\-]+$/,
      message: "ID must be only contain letters, numbers and a dash."
    )
    |> put_timestamp_if_nil(:created_at)
    #|> put_timestamp_if_nil(:opened_at)
    #|> ensure_identifier_format(:identifier, :created_at)
    #|> truncate_field(:freetext, 65_535)
    #|> unique_constraint(:identifier)
  end

  # Check the ID for year suffix
  defp ensure_identifier_format(changeset, field, fallback_time) do
    current_value = get_field(changeset, field)

    case current_value do
      nil -> changeset
      _ ->
        fixed_id = get_compound_identifier(current_value, get_field(changeset, fallback_time))
        put_change(changeset, field, fixed_id)
    end

  end

  def get_compound_identifier(id, fallback_time) when is_binary(id) do
    case String.split(id, "-") do
      [_num, _year] -> id
      [num] ->
        year = DateTime.to_date(fallback_time).year
        "#{num}-#{year}"
      [_num, _year | _tail] -> id
    end
  end
end
