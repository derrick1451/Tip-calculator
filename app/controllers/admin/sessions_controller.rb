# frozen_string_literal: true

module Admin
  class SessionsController < ApplicationController
    layout "admin_login"

    # GET /admin/login
    def new
      # Redirect if already logged in
      redirect_to admin_dashboard_path if admin_logged_in?
    end

    # POST /admin/login
    def create
      if valid_credentials?
        session[:admin_logged_in] = true
        session[:admin_logged_in_at] = Time.current
        redirect_to admin_dashboard_path, notice: "Welcome to the admin dashboard!"
      else
        flash.now[:alert] = "Invalid username or password"
        render :new, status: :unprocessable_entity
      end
    end

    # DELETE /admin/logout
    def destroy
      session[:admin_logged_in] = nil
      session[:admin_logged_in_at] = nil
      redirect_to root_path, notice: "You have been logged out."
    end

    private

    def valid_credentials?
      params[:username] == admin_username && params[:password] == admin_password
    end

    def admin_username
      ENV.fetch("ADMIN_USERNAME", "admin")
    end

    def admin_password
      ENV.fetch("ADMIN_PASSWORD", "tipcalculator2026")
    end

    def admin_logged_in?
      session[:admin_logged_in] == true
    end
  end
end
