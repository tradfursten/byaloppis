defmodule ByaloppisWeb.Router do
  use ByaloppisWeb, :router

  import ByaloppisWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ByaloppisWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ByaloppisWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/events", EventLive.Index, :index
    live "/events/new", EventLive.Index, :new
    live "/events/:id/edit", EventLive.Index, :edit

    live "/events/:id", EventLive.Show, :show
    live "/events/:id/tables/new", EventLive.Index, :new_table
    live "/events/:id/show/edit", EventLive.Show, :edit

    live "/tables", TableLive.Index, :index
    live "/tables/new", TableLive.Index, :new
    live "/tables/:id/edit", TableLive.Index, :edit

    live "/tables/:id", TableLive.Show, :show
    live "/tables/:id/show/edit", TableLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", ByaloppisWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:byaloppis, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ByaloppisWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", ByaloppisWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{ByaloppisWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", ByaloppisWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{ByaloppisWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

    end
  end

  scope "/", ByaloppisWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{ByaloppisWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
