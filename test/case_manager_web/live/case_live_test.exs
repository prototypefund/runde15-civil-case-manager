defmodule CaseManagerWeb.CaseLiveTest do
  use CaseManagerWeb.ConnCase

  import Phoenix.LiveViewTest
  import CaseManager.CasesFixtures
  import CaseManagerWeb.LoginUtils

  @create_attrs %{
    name: "AP9001",
    notes: "some notes",
    status: :open,
    occurred_at: ~U[2024-03-07 08:58:00Z],
    departure_region: "some departure_region",
    place_of_departure: "some place_of_departure",
    time_of_departure: ~U[2024-03-07 08:58:00Z],
    sar_region: :sar1,
    phonenumber: "some phonenumber",
    alarmphone_contact: "some alarmphone_contact",
    confirmation_by: "some confirmation_by",
    actors_involved: "some actors_involved",
    authorities_alerted: true,
    authorities_details: "some authorities_details",
    boat_type: :rubber,
    boat_notes: "some boat_notes",
    boat_color: :red,
    boat_engine_status: "some boat_engine_status",
    boat_engine_working: "some boat_engine_working",
    boat_number_of_engines: 42,
    pob_total: 42,
    pob_men: 42,
    pob_women: 42,
    pob_minors: 42,
    pob_gender_ambiguous: 42,
    pob_medical_cases: 42,
    people_dead: 42,
    people_missing: 42,
    pob_per_nationality: "some pob_per_nationality",
    outcome: :currently_unknown,
    time_of_disembarkation: ~U[2024-03-07 08:58:00Z],
    place_of_disembarkation: "some place_of_disembarkation",
    disembarked_by: "some disembarked_by",
    outcome_actors: "some outcome_actors",
    frontext_involvement: "some frontext_involvement",
    followup_needed: true,
    url: "some url",
    cloud_file_links: "some cloud_file_links"
  }
  @update_attrs %{
    name: "DC1001",
    notes: "some updated notes",
    status: :ready_for_documentation,
    occurred_at: ~U[2024-03-08 08:58:00Z],
    departure_region: "some updated departure_region",
    place_of_departure: "some updated place_of_departure",
    time_of_departure: ~U[2024-03-08 08:58:00Z],
    sar_region: :sar2,
    phonenumber: "some updated phonenumber",
    alarmphone_contact: "some updated alarmphone_contact",
    confirmation_by: "some updated confirmation_by",
    actors_involved: "some updated actors_involved",
    authorities_alerted: false,
    authorities_details: "some updated authorities_details",
    boat_type: :wood,
    boat_notes: "some updated boat_notes",
    boat_color: :green,
    boat_engine_status: "some updated boat_engine_status",
    boat_engine_working: "some updated boat_engine_working",
    boat_number_of_engines: 43,
    pob_total: 43,
    pob_men: 43,
    pob_women: 43,
    pob_minors: 43,
    pob_gender_ambiguous: 43,
    pob_medical_cases: 43,
    people_dead: 43,
    people_missing: 43,
    pob_per_nationality: "some updated pob_per_nationality",
    outcome: :interception_libya,
    time_of_disembarkation: ~U[2024-03-08 08:58:00Z],
    place_of_disembarkation: "some updated place_of_disembarkation",
    disembarked_by: "some updated disembarked_by",
    outcome_actors: "some updated outcome_actors",
    frontext_involvement: "some updated frontext_involvement",
    followup_needed: false,
    url: "some updated url",
    cloud_file_links: "some updated cloud_file_links"
  }

  @invalid_attrs %{
    name: nil
  }

  @invalid_name %{
    name: "DC100 AC2300"
  }

  @invalid_status %{
    status: :random
  }

  defp create_case(_) do
    case = case_fixture()
    %{caseStruct: case}
  end

  describe "Anonymous user" do
    test "cannot list cases", %{conn: conn} do
      {:error, _} = live(conn, ~p"/cases")
    end
  end

  describe "Index" do
    setup [:create_case, :login]

    test "lists all cases", %{conn: conn, caseStruct: case} do
      {:ok, _index_live, html} = live(conn, ~p"/cases")

      assert html =~ "Listing Cases"
      assert html =~ case.name
    end

    test "saves new case", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/cases")

      assert index_live |> element("a", "New Case") |> render_click() =~
               "New Case"

      assert_patch(index_live, ~p"/cases/new")

      assert index_live
             |> form("#case-form", case: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#case-form", case: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cases")

      html = render(index_live)
      assert html =~ "Case created successfully"
      assert html =~ "some notes"
    end

    ## FIXME
    # test "readonly user cannot save case", %{conn: conn} do
    #   {:ok, index_live, _html} = live(conn, ~p"/cases")

    #   assert index_live |> element("a", "New Case") |> has_element?() == false
    # end

    test "updates case in listing", %{conn: conn, caseStruct: case} do
      {:ok, index_live, _html} = live(conn, ~p"/cases")

      assert index_live |> element("#cases-#{case.id} a", "Edit") |> render_click() =~
               "Edit Case"

      assert_patch(index_live, ~p"/cases/#{case}/edit")

      ## TODO Test for wrong status
      assert index_live
             |> form("#case-form", case: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#case-form", case: @invalid_name)
             |> render_change() =~ "ID must only contain letters, numbers and a dash"

      assert_raise ArgumentError, fn ->
        index_live
        |> form("#case-form", case: @invalid_status)
        |> render_change() =~ "must be one of"
      end

      assert index_live
             |> form("#case-form", case: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/cases")

      html = render(index_live)
      assert html =~ "Case updated successfully"
      assert html =~ "some updated notes"
    end

    test "deletes case in listing", %{conn: conn, caseStruct: case} do
      {:ok, index_live, _html} = live(conn, ~p"/cases")

      assert index_live |> element("#cases-#{case.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cases-#{case.id}")
    end
  end

  describe "Show" do
    setup [:create_case, :login]

    test "displays case", %{conn: conn, caseStruct: case} do
      {:ok, _show_live, html} = live(conn, ~p"/cases/#{case}")

      assert html =~ "Show Case"
      assert html =~ case.name
    end

    test "updates case within modal", %{conn: conn, caseStruct: case} do
      {:ok, show_live, _html} = live(conn, ~p"/cases/#{case}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Case"

      assert_patch(show_live, ~p"/cases/#{case}/show/edit")

      assert show_live
             |> form("#case-form", case: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#case-form", case: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/cases/#{case}")

      html = render(show_live)
      assert html =~ "Case updated successfully"
      assert html =~ "some updated notes"
    end
  end
end
