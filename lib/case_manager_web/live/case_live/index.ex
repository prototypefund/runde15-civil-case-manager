defmodule CaseManagerWeb.CaseLive.Index do
  use CaseManagerWeb, :live_view

  require Logger

  alias CaseManager.Cases
  alias CaseManager.Cases.Case
  import CaseManagerWeb.LiveUtils

  import CaseManagerWeb.LiveComponents

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
  def handle_info({:case_created, case}, socket) do
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  @impl true
  def handle_info({:case_updated, case}, socket) do
    {:noreply, stream_insert(socket, :cases, case, at: 0)}
  end

  @impl true
  def handle_info({CaseManagerWeb.CaseLive.FormComponent, {:saved, case}}, socket) do
    {:noreply, stream_insert(socket, :cases, case)}
  end

  @impl true
  def handle_event("update-filter", params, socket) do
    params = Map.delete(params, "_target")
    {:noreply, push_patch(socket, to: ~p"/cases?#{params}")}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if socket.assigns.current_user.role != :readonly do
      case = Cases.get_case!(id)
      {:ok, _} = Cases.delete_case(case)

      {:noreply, stream_delete(socket, :cases, case)}
    else
      Logger.warning(
        "User #{socket.assigns.current_user.email} tried to delete case, but is a read-only user."
      )

      {:noreply,
       socket
       |> put_flash(:error, "Method not allowed")}
    end
  end

  defp get_color_for_year_tag(case) do
    year = Cases.get_year_from_id(case)

    if year do
      if year == Integer.to_string(Date.utc_today().year) do
        "emerald"
      else
        "gray"
      end
    end
  end

  attr :status, :atom, required: true
  attr :class, :string, default: ""

  def status_icon(%{status: status} = assigns) do
    icon_name =
      case status do
        :open -> "hero-inbox-solid text-emerald-500"
        :closed -> "hero-lock-closed text-gray-500"
        :archived -> "hero-archive-box text-gray-500"
        _ -> "hero-question-mark-circle text-blue-500"
      end

    assigns = assign(assigns, :icon_name, icon_name)
    ~H"<span class={[@icon_name, @class]} />"
  end
end
