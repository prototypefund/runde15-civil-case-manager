defmodule CaseManager.Cases.Case do
  use Ecto.Schema

  import Ecto.Changeset
  import CaseManager.ChangesetValidators

  alias CaseManager.CaseNationalities.CaseNationality

  @derive {
    Flop.Schema,
    filterable: [:status, :name, :occurred_at, :outcome, :actors_involved],
    sortable: [:name, :occurred_at],
    default_order: %{
      order_by: [:occurred_at],
      order_directions: [:desc, :asc]
    }
  }

  ## Refer to https://gitlab.com/civilmrcc/onefleet/-/blob/develop/src/constants/templates/case.ts
  ## for possible values
  @primary_key {:id, CaseManager.StringId, autogenerate: true}
  schema "cases" do
    ## Base data
    field :name, :string
    field :notes, :string

    field :status, Ecto.Enum,
      values: [
        :open,
        :ready_for_documentation,
        :closed
      ]

    field :occurred_at, :utc_datetime

    ## Departure
    field :departure_region, :string

    ### Deprecated
    field :place_of_departure, :string

    belongs_to :departure_place,
               CaseManager.Places.Place,
               foreign_key: :departure_id,
               type: :id

    field :time_of_departure, :utc_datetime

    field :sar_region, Ecto.Enum,
      values: [
        :unknown,
        :sar1,
        :sar2,
        :sar3
      ]

    ## Involved parties
    field :phonenumber, :string
    field :alarmphone_contact, :string
    field :confirmation_by, :string
    field :actors_involved, :string
    field :authorities_alerted, :string
    field :authorities_details, :string
    field :alerted_at, :utc_datetime
    field :alerted_by, :string

    ## The boat
    field :boat_type, Ecto.Enum,
      values: [
        :unknown,
        :rubber,
        :wood,
        :iron,
        :fiberglass,
        :fishing_vessel,
        :other,
        :sailing
      ]

    field :boat_notes, :string

    field :boat_color, Ecto.Enum,
      values: [
        :unknown,
        :black,
        :blue,
        :brown,
        :gray,
        :green,
        :other,
        :red,
        :white,
        :yellow
      ]

    field :boat_engine_status, :string

    field :boat_engine_failure, Ecto.Enum,
      values: [
        :unknown,
        :yes,
        :no
      ]

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

    has_many :nationalities, CaseNationality, on_replace: :delete

    ## Outcome

    field :outcome, Ecto.Enum,
      values: [
        :unknown,
        :interception_libya,
        :interception_tn,
        :ngo_rescue,
        :afm_rescue,
        :hcg_rescue,
        :italy_rescue,
        :merv_interception,
        :merv_rescue,
        :returned,
        :arrived,
        :autonomous,
        :empty_boat,
        :shipwreck,
        :unclear,
        ## TODO Remove in dagster
        :currently_unknown
      ]

    field :time_of_disembarkation, :utc_datetime

    ### Deprecated
    field :place_of_disembarkation, :string

    belongs_to :arrival_place,
               CaseManager.Places.Place,
               foreign_key: :arrival_id,
               type: :id

    field :disembarked_by, :string
    field :outcome_actors, :string
    field :frontext_involvement, :string
    field :followup_needed, :boolean

    ## Meta
    field :template, :string
    field :source, :string
    field :url, :string
    field :cloud_file_links, :string
    field :imported_from, :string

    has_many :positions, CaseManager.Positions.Position,
      foreign_key: :item_id,
      on_replace: :delete

    many_to_many :events, CaseManager.Events.Event, join_through: CaseManager.CasesEvents

    # Use created_at as timestamp key
    timestamps(inserted_at: :created_at, type: :utc_datetime)
  end

  @doc false
  def changeset(case, attrs) do
    case
    |> cast(attrs, [
      :notes,
      :name,
      :status,
      :created_at,
      :occurred_at,
      :departure_region,
      :place_of_departure,
      :departure_id,
      :time_of_departure,
      :sar_region,
      :phonenumber,
      :alarmphone_contact,
      :confirmation_by,
      :actors_involved,
      :authorities_alerted,
      :authorities_details,
      :boat_type,
      :boat_notes,
      :boat_color,
      :boat_engine_status,
      :boat_engine_failure,
      :boat_number_of_engines,
      :pob_total,
      :pob_men,
      :pob_women,
      :pob_minors,
      :pob_gender_ambiguous,
      :pob_medical_cases,
      :people_dead,
      :people_missing,
      :pob_per_nationality,
      :outcome,
      :time_of_disembarkation,
      :place_of_disembarkation,
      :arrival_id,
      :disembarked_by,
      :outcome_actors,
      :frontext_involvement,
      :followup_needed,
      :source,
      :url,
      :cloud_file_links,
      :imported_from,
      :alerted_at,
      :alerted_by
    ])
    |> validate_required([:name, :status])
    # |> validate_number(:course_over_ground, greater_than_or_equal_to: 0, less_than_or_equal_to: 360)
    # |> validate_format(
    #   :name,
    #   ~r/^[a-zA-Z0-9\-]+$/,
    #   message: "ID must only contain letters, numbers and a dash."
    # )
    |> put_timestamp_if_nil(:created_at)
    |> cast_assoc(:positions,
      sort_param: :positions_sort,
      drop_param: :positions_drop
    )
    |> cast_assoc(:nationalities,
      sort_param: :nationalities_sort,
      drop_param: :nationalities_drop
    )

    # |> put_timestamp_if_nil(:opened_at)
    # |> ensure_identifier_format(:identifier, :created_at)
    # |> truncate_field(:freetext, 65_535)
    # |> unique_constraint(:identifier)
  end

  # Check the ID for year suffix
  # defp ensure_identifier_format(changeset, field, fallback_time) do
  #   current_value = get_field(changeset, field)

  #   case current_value do
  #     nil ->
  #       changeset

  #     _ ->
  #       fixed_id = get_compound_identifier(current_value, get_field(changeset, fallback_time))
  #       put_change(changeset, field, fixed_id)
  #   end
  # end

  def get_compound_identifier(id, fallback_time) when is_binary(id) do
    case String.split(id, "-") do
      [_num, _year] ->
        id

      [num] ->
        year = DateTime.to_date(fallback_time).year
        "#{num}-#{year}"

      [_num, _year | _tail] ->
        id
    end
  end
end
