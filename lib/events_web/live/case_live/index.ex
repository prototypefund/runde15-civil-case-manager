defmodule EventsWeb.CaseLive.Index do
  use EventsWeb, :live_view

  alias Events.Cases
  alias Events.Cases.Case

  use PhoenixHTMLHelpers

  import EventsWeb.LiveComponents

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Cases.subscribe()
    {:ok, stream(socket, :cases, [])}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Case")
    |> assign(:case, Cases.get_case!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Case")
    |> assign(:case, %Case{})
  end

  defp apply_action(socket, :index, params) do
    case Cases.list_cases(params) do
      {:ok, {cases, meta}} ->
        socket
          |> assign(:meta, meta)
          |> stream(:cases, cases, reset: true)
          |> assign(:page_title, "Listing Cases")
          |> assign(:case, nil)

      {:error, _meta} ->
        # This will reset invalid parameters. Alternatively, you can assign
        # only the meta and render the errors, or you can ignore the error
        # case entirely.
        push_navigate(socket, to: ~p"/cases")
    end
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/cases?#{params}")}
  end

  @impl true
  def handle_info({:case_created, case}, socket) do
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  @impl true
  def handle_info({:case_updated, case}, socket) do
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  @impl true
  def handle_info({EventsWeb.CaseLive.FormComponent, {:saved, case}}, socket) do
    {:noreply, stream_insert(socket, :cases, case)}
  end


  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    case = Cases.get_case!(id)
    {:ok, _} = Cases.delete_case(case)

    {:noreply, stream_delete(socket, :cases, case)}
  end

  defp render_timestamp(case) do
    now = DateTime.utc_now()
    diff = DateTime.diff(now, case.created_at)

    timestamp = cond do
      diff < 60 ->
        "#{diff} seconds ago"
      diff < 3600 ->
        "#{div(diff, 60)} minutes ago"
      diff < 86400 ->
        "#{div(diff, 3600)} hours ago"
      true ->
        "#{Date.to_string(case.created_at)}"
    end

    content_tag(:span, class: "flex items-center gap-1 text-xs") do
      [
        content_tag(:i, "", class: "hero-clock text-gray-700 h-3 w-3"),
        timestamp
      ]
    end
  end

  defp get_pretty_identifier(case) do
    # Get first part of identifier
    case.identifier
    |> String.split("-")
    |> hd()
  end

  defp get_year_from_id(case) do
    # Get second part of identifier or nothing if it doesn't exist
    case.identifier
    |> String.split("-")
    |> tl()
    |> Enum.at(0)
  end

  defp get_color_for_year_tag(case) do
    year = get_year_from_id(case)

    if (year) do
      if year == Integer.to_string(Date.utc_today().year) do
        "emerald"
      else
        "gray"
      end
    end
  end

  ## Render an icon based on the case status
  defp render_status_icon(case, classes) do
    icon_name = case case.status do
      :open -> "hero-inbox-solid text-emerald-500"
      :closed -> "hero-lock-closed text-gray-500"
      :archived -> "hero-archive-box text-gray-500"
      _ -> "hero-question-mark-circle text-blue-500"
    end

    content_tag(:span, class: "#{icon_name} #{classes}") do

    end

  end
end
