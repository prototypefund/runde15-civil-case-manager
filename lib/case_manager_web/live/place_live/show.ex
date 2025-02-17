defmodule CaseManagerWeb.PlaceLive.Show do
  use CaseManagerWeb, :live_view

  alias CaseManager.Places

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:place, Places.get_place!(id))}
  end

  defp page_title(:show), do: "Show Place"
  defp page_title(:edit), do: "Edit Place"
end
