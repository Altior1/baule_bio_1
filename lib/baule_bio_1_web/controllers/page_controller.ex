defmodule BauleBio1Web.PageController do
  use BauleBio1Web, :controller

  def home(conn, _params) do
    render(conn, :home, current_scope: conn.assigns[:current_scope])
  end
end
