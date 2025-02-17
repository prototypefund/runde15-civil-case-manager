defmodule CaseManagerWeb.CaseForm do
  require Logger

  use CaseManagerWeb, :live_component

  alias CaseManager.Cases

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <%= if assigns[:flash_copy] && @flash_copy["info"] do %>
        <div
          id="loader"
          class="fixed inset-0 flex items-center justify-center z-1  text-4xl font-bold "
          style="animation: fadeOut 700ms 100ms forwards, hide 800ms 1ms forwards;"
        >
          <div class="p-5 rounded-lg bg-gray-800 bg-opacity-75 text-white">Opening next Case...</div>
        </div>
      <% end %>

      <.header>
        <%= @title %>
        <:subtitle :if={assigns[:subtitle]}><%= @subtitle %></:subtitle>
        <:actions :if={assigns[:imported_case]}>
          <.link
            phx-click={JS.push("delete", value: %{imported_id: @imported_case.id})}
            data-confirm="Are you sure?"
          >
            <.button class="!bg-rose-600 text-white">Delete row</.button>
          </.link>
        </:actions>
      </.header>

      <.simple_form
        for={@form}
        id="case-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="pb-4 pr-4"
      >
        <%= if assigns[:imported_case] do %>
          <.input field={@form[:imported_id]} type="hidden" value={@imported_case.id} />
        <% end %>
        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">Base data</h1>
        <.input
          field={@form[:name]}
          type="text"
          label="Identifier"
          placeholder="Example: AP0001-2024"
          force_validate={@validate_now}
        />
        <.input field={@form[:notes]} type="textarea" label="Notes" force_validate={@validate_now} />

        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={Ecto.Enum.values(CaseManager.Cases.Case, :status)}
        />
        <%= if assigns[:imported_case] && @imported_case.occurred_at_string do %>
          <.parsing_hint field_name="Occurred at">
            <%= @imported_case.occurred_at_string %>
          </.parsing_hint>
        <% end %>
        <.input
          field={@form[:occurred_at]}
          type="datetime-local"
          label="Occurred at"
          force_validate={@validate_now}
        />

        <%= if assigns[:imported_case] && @imported_case.time_of_departure_string do %>
          <.parsing_hint field_name="Time of departure">
            <%= @imported_case.time_of_departure_string %>
          </.parsing_hint>
        <% end %>
        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">Departure</h1>

        <%= if !Ecto.Changeset.get_field(@form.source, :departure_id) do %>
          <.input
            field={@form[:departure_region]}
            type="select"
            label="Departure Region"
            options={CaseManager.Places.valid_departure_regions()}
            add_invalid_options={true}
            force_validate={@validate_now}
          />
        <% end %>
        <%= if Ecto.Changeset.get_field(@form.source, :place_of_departure) do %>
          <.parsing_hint use_structured={true}>
            <%= Ecto.Changeset.get_field(@form.source, :place_of_departure) %>
          </.parsing_hint>
          <.input
            field={@form[:place_of_departure]}
            type="text"
            label="Place of departure custom value"
          />
        <% else %>
          <.input field={@form[:place_of_departure]} type="hidden" value />
        <% end %>
        <.input
          field={@form[:departure_id]}
          type="select"
          label="Departure Place"
          prompt="Select departure place"
          options={CaseManager.Places.get_places_for_select(:departure)}
        />
        <.input
          field={@form[:time_of_departure]}
          type="datetime-local"
          label="Time of Departure"
          force_validate={@validate_now}
        />

        <.input
          field={@form[:sar_region]}
          type="select"
          label="SAR Region"
          options={Ecto.Enum.values(CaseManager.Cases.Case, :sar_region)}
          add_invalid_options={true}
        />

        <div class="flex between items-baseline justify-between">
          <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold grow">Positions</h1>
          <button
            type="button"
            name="case[positions_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
            class={[
              "phx-submit-loading:opacity-75 rounded-lg bg-emerald-600 hover:dark:bg-emerald-700 w-9 h-9 py-1 px-2",
              "text-sm font-semibold leading-5 text-white active:text-white/80"
            ]}
          >
            <.icon name="hero-plus-circle" class="w-5 h-5 text-white" />
          </button>
          <%= if assigns[:imported_case] && @imported_case.first_position do %>
            <.parsing_hint field_name="First position">
              <%= @imported_case.first_position %>
            </.parsing_hint>
          <% end %>
          <%= if assigns[:imported_case] && @imported_case.last_position do %>
            <.parsing_hint field_name="Last position">
              <%= @imported_case.last_position %>
            </.parsing_hint>
          <% end %>
        </div>
        <.inputs_for :let={ef} field={@form[:positions]}>
          <div class="break-inside-avoid-column flex flex-row gap-4">
            <input type="hidden" name="case[positions_sort][]" value={ef.index} />
            <.input
              type="text"
              field={ef[:short_code]}
              placeholder="DEG MIN (SEC) / DEG MIN (SEC)"
              wrapper_class="flex-grow"
            />
            <.input type="datetime-local" field={ef[:timestamp]} wrapper_class="flex-grow" />
            <button
              type="button"
              name="case[positions_drop][]"
              value={ef.index}
              class="w-9 h-9 mt-2 bg-rose-600 hover:bg-rose-700 rounded-lg py-1 px-2"
              phx-click={JS.dispatch("change")}
              data-confirm="Are you sure to delete this position?"
            >
              <.icon name="hero-trash" class="w-5 h-5 text-white" />
            </button>
          </div>
        </.inputs_for>

        <input type="hidden" name="case[positions_drop][]" />

        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">Involved parties</h1>
        <.input
          field={@form[:phonenumber]}
          type="text"
          label="Phone number"
          force_validate={@validate_now}
        />
        <.input
          field={@form[:actors_involved]}
          type="text"
          label="Actors involved"
          force_validate={@validate_now}
        />
        <.input field={@form[:authorities_alerted]} type="text" label="Authorities alerted" />
        <.input
          field={@form[:authorities_details]}
          type="text"
          label="Details about contact w/ authorities"
        />
        <.input field={@form[:alerted_by]} type="text" label="Alerted by whom" />
        <.input field={@form[:alerted_at]} type="datetime-local" label="Time of first alert" />

        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">The boat</h1>
        <.input
          field={@form[:boat_type]}
          type="select"
          label="Boat Type"
          options={Ecto.Enum.values(CaseManager.Cases.Case, :boat_type)}
          add_invalid_options={true}
        />
        <.input
          field={@form[:boat_notes]}
          type="text"
          label="Boat Notes"
          force_validate={@validate_now}
        />
        <.input
          field={@form[:boat_color]}
          type="select"
          label="Boat Color"
          options={Ecto.Enum.values(CaseManager.Cases.Case, :boat_color)}
          add_invalid_options={true}
        />
        <.input
          field={@form[:boat_engine_failure]}
          type="radiogroup"
          label="Boat Engine Failed"
          options={Ecto.Enum.values(CaseManager.Cases.Case, :boat_engine_failure)}
          add_invalid_options={true}
          force_validate={@validate_now}
        />

        <%= if assigns[:imported_case] && @imported_case.boat_number_of_engines_string do %>
          <.parsing_hint field_name="Number of engines">
            <%= @imported_case.boat_number_of_engines_string %>
          </.parsing_hint>
        <% end %>
        <.input
          field={@form[:boat_number_of_engines]}
          type="number"
          label="Boat Number of Engines"
          force_validate={@validate_now}
        />

        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">People on Board</h1>
        <div class="flex gap-4 flex-row flex-wrap">
          <%= if assigns[:imported_case] && @imported_case.pob_total_string do %>
            <.parsing_hint field_name="POB Total">
              <%= @imported_case.pob_total_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:pob_total]}
            type="number"
            label="Total"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <%= if assigns[:imported_case] && @imported_case.pob_men_string do %>
            <.parsing_hint field_name="Men">
              <%= @imported_case.pob_men_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:pob_men]}
            type="number"
            label="Men"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <%= if assigns[:imported_case] && @imported_case.pob_women_string do %>
            <.parsing_hint field_name="Women">
              <%= @imported_case.pob_women_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:pob_women]}
            type="number"
            label="Women"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <%= if assigns[:imported_case] && @imported_case.pob_minors_string do %>
            <.parsing_hint field_name="Minors">
              <%= @imported_case.pob_minors_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:pob_minors]}
            type="number"
            label="Minors"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <%= if assigns[:imported_case] && @imported_case.pob_gender_ambiguous_string do %>
            <.parsing_hint field_name="Gender ambigous">
              <%= @imported_case.pob_gender_ambiguous_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:pob_gender_ambiguous]}
            type="number"
            label="Gender ambigous"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <.input
            field={@form[:pob_medical_cases]}
            type="number"
            label="Medical Cases"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <%= if assigns[:imported_case] && @imported_case.people_dead_string do %>
            <.parsing_hint field_name="People dead">
              <%= @imported_case.people_dead_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:people_dead]}
            type="number"
            label="Dead"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
          <%= if assigns[:imported_case] && @imported_case.people_missing_string do %>
            <.parsing_hint field_name="People missing">
              <%= @imported_case.people_missing_string %>
            </.parsing_hint>
          <% end %>
          <.input
            field={@form[:people_missing]}
            type="number"
            label="Missing"
            wrapper_class="w-2/5 flex-grow"
            force_validate={true}
          />
        </div>
        <h2 class="dark:text-indigo-300 text-indigo-600 pt-4 font-semibold">
          Nationalities on Board
        </h2>
        <%= if assigns[:imported_case] && @imported_case.pob_per_nationality do %>
          <.parsing_hint field_name="Nationalities">
            <%= @imported_case.pob_per_nationality %>
          </.parsing_hint>
        <% end %>
        <div id="nationalities-container">
          <details>
            <summary>
              <.nationalities_summary
                nationalities={Ecto.Changeset.get_field(@form.source, :nationalities)}
                use_bold={true}
              />
            </summary>
            <.inputs_for :let={f_nat} field={@form[:nationalities]}>
              <div class="flex items-center space-x-2 mb-2" id={"nationality-#{f_nat.index}"}>
                <.input
                  field={f_nat[:country]}
                  type="select"
                  options={CaseManager.CountryCodes.get_country_codes()}
                  add_invalid_options={true}
                />
                <.input
                  field={f_nat[:count]}
                  type="number"
                  min="0"
                  placeholder="Leave empty if unknown"
                />
                <button
                  type="button"
                  name="case[nationalities_drop][]"
                  value={f_nat.index}
                  class="w-9 h-9 mt-2 bg-rose-600 hover:bg-rose-700 rounded-lg py-1 px-2"
                  phx-click={JS.dispatch("change")}
                >
                  <.icon name="hero-trash" class="w-5 h-5 text-white" />
                </button>
              </div>
            </.inputs_for>
            <button
              type="button"
              name="case[nationalities_sort][]"
              value="new"
              phx-click={JS.dispatch("change")}
              class={[
                "phx-submit-loading:opacity-75 rounded-lg bg-emerald-600 hover:dark:bg-emerald-700  py-2 px-3",
                "text-sm font-semibold leading-5 text-white active:text-white/80"
              ]}
            >
              Add Nationality
            </button>
            <input type="hidden" name="case[nationalities_drop][]" />
          </details>
        </div>

        <div class="flex between items-baseline justify-between">
          <h2 class="dark:text-indigo-300 text-indigo-600 pt-4 font-semibold">
            Individual Passengers
          </h2>
          <button
            type="button"
            name="case[passengers_sort][]"
            value="new"
            phx-click={JS.dispatch("change")}
            class={[
              "phx-submit-loading:opacity-75 rounded-lg bg-emerald-600 hover:dark:bg-emerald-700 w-9 h-9 py-1 px-2",
              "text-sm font-semibold leading-5 text-white active:text-white/80"
            ]}
          >
            <.icon name="hero-plus-circle" class="w-5 h-5 text-white" />
          </button>
        </div>
        <.inputs_for :let={ef} field={@form[:passengers]}>
          <div class="break-inside-avoid-column flex flex-row gap-4">
            <input type="hidden" name="case[passengers_sort][]" value={ef.index} />
            <.input
              type="text"
              field={ef[:name]}
              placeholder="Name of person"
              wrapper_class="flex-grow"
            />
            <.input
              type="textarea"
              field={ef[:description]}
              wrapper_class="flex-grow"
              placeholder="Details of the person"
            />
            <button
              type="button"
              name="case[passengers_drop][]"
              value={ef.index}
              class="w-9 h-9 mt-2 bg-rose-600 hover:bg-rose-700 rounded-lg py-1 px-2"
              phx-click={JS.dispatch("change")}
              data-confirm="Are you sure to delete this passenger?"
            >
              <.icon name="hero-trash" class="w-5 h-5 text-white" />
            </button>
          </div>
        </.inputs_for>

        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">Outcome</h1>
        <.input
          field={@form[:outcome]}
          type="select"
          label="Outcome"
          options={Ecto.Enum.values(CaseManager.Cases.Case, :outcome)}
          add_invalid_options={true}
        />

        <%= if assigns[:imported_case] && @imported_case.time_of_disembarkation_string do %>
          <.parsing_hint field_name="Time of disembarkation">
            <%= @imported_case.time_of_disembarkation_string %>
          </.parsing_hint>
        <% end %>

        <.input
          field={@form[:time_of_disembarkation]}
          type="datetime-local"
          label="Time of Disembarkation"
        />

        <.input
          field={@form[:arrival_id]}
          type="select"
          label="Arrival Place"
          prompt="Select arrival place"
          options={CaseManager.Places.get_places_for_select(:arrival)}
        />
        <%= if !Ecto.Changeset.get_field(@form.source, :arrival_id) do %>
          <.warning :if={Ecto.Changeset.get_field(@form.source, :place_of_disembarkation)}>
            Please use this field only for cases with multiple arrival ports. If this case has only one arrival port, please select it above and clear this field.
          </.warning>
          <.input field={@form[:place_of_disembarkation]} type="text" label="Multiple Arrival Places" />
        <% end %>
        <.input
          field={@form[:disembarked_by]}
          type="text"
          label="Disembarked by"
          force_validate={@validate_now}
        />
        <.input
          field={@form[:outcome_actors]}
          type="text"
          label="Outcome Actors"
          force_validate={@validate_now}
        />

        <%= if assigns[:imported_case] && @imported_case.followup_needed_string do %>
          <.parsing_hint field_name="Followup needed">
            <%= @imported_case.followup_needed_string %>
          </.parsing_hint>
        <% end %>

        <.input
          field={@form[:followup_needed]}
          type="checkbox"
          label="Followup needed"
          force_validate={@validate_now}
        />

        <h1 class="dark:text-indigo-300 text-indigo-600 pt-8 font-semibold">Meta</h1>
        <.input
          field={@form[:url]}
          type="textarea"
          label="URLs"
          force_validate={@validate_now}
          placeholder="Add one link per line"
        />

        <%= if !@case.id do %>
          <.input
            field={@form[:imported_from]}
            type="hidden"
            value={if assigns[:imported_case], do: "cm-excel", else: "cm-form"}
          />
        <% end %>

        <:actions>
          <.button phx-disable-with="Saving...">Save Case</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{imported_case: imported_case, action: :import} = assigns, socket) do
    changeset = Cases.change_case(assigns.case, Map.from_struct(imported_case))

    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(changeset, action: :validate)
     end)}
  end

  def update(%{case: case} = assigns, socket) do
    changeset = Cases.change_case(case)

    # If there are already changes and put another user has published other changes,
    # reapply the current changeset on to the new case.
    changeset =
      if socket.assigns[:form] do
        existing_changes = socket.assigns.form.source.changes
        Cases.change_case(case, existing_changes)
      else
        changeset
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"case" => case_params}, socket) do
    changeset =
      Cases.change_case(socket.assigns.case, case_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"case" => case_params}, socket) do
    CaseManagerWeb.UserLive.Auth.run_if_user_can_write(socket, Cases.Case, fn ->
      save_case(socket, socket.assigns.action, case_params)
    end)
  end

  defp save_case(socket, :edit, case_params) do
    case Cases.update_case(socket.assigns.case, case_params) do
      {:ok, case} ->
        notify_parent({:saved, case})

        {:noreply,
         socket
         |> put_flash(:info, "Case updated successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Error updating case: #{inspect(changeset)}")

        {:noreply,
         socket
         |> assign(:form, to_form(changeset, action: :validate))}
    end
  end

  defp save_case(socket, :new, case_params) do
    case Cases.create_case(case_params) do
      {:ok, case} ->
        notify_parent({:saved, case})

        {:noreply,
         socket
         |> put_flash(:info, "Case created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_case(socket, :import, case_params) do
    case Cases.create_case_and_delete_imported(
           case_params,
           socket.assigns.imported_case
         ) do
      {:ok, %{insert_case: case}} ->
        {:noreply,
         socket
         |> push_event("transition", %{name: "Case"})
         |> assign(transition: true)
         |> put_flash(:info, "Case #{case.name} added to the main database successfully")
         |> push_navigate(to: socket.assigns.patch)}

      {:error, :insert_case, %Ecto.Changeset{} = changeset, _} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
