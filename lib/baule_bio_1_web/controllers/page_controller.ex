defmodule BauleBio1Web.PageController do
  use BauleBio1Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
