# frozen_string_literal: true

module Admin
  class DashboardController < ApplicationController
    before_action :require_admin_login

    # Number of records per page
    RECORDS_PER_PAGE = 20

    # GET /admin/dashboard
    # Display all calculations with pagination and sorting
    def index
      @calculations = fetch_calculations
      @statistics = calculate_statistics
      @current_page = current_page
      @total_pages = total_pages
      @sort_column = sort_column
      @sort_direction = sort_direction
    end

    private

    # Session-based authentication
    def require_admin_login
      unless admin_logged_in?
        redirect_to admin_login_path, alert: "Please log in to access the admin dashboard."
      end
    end

    def admin_logged_in?
      session[:admin_logged_in] == true
    end

    # Fetch calculations with sorting and pagination
    def fetch_calculations
      calculations = Calculation.all

      # Apply sorting
      calculations = apply_sorting(calculations)

      # Apply pagination
      calculations.offset(pagination_offset).limit(RECORDS_PER_PAGE)
    end

    # Apply sorting based on params
    def apply_sorting(calculations)
      case sort_column
      when "bill_amount"
        calculations.by_bill_amount(sort_direction)
      when "tip_percentage"
        calculations.by_tip_percentage(sort_direction)
      else
        calculations.by_date(sort_direction)
      end
    end

    # Calculate summary statistics
    def calculate_statistics
      {
        total_calculations: Calculation.total_count,
        average_tip_percentage: Calculation.average_tip_percentage,
        average_bill_amount: Calculation.average_bill_amount,
        total_tips_collected: Calculation.total_tips_collected,
        average_party_size: Calculation.average_party_size
      }
    end

    # Get current page number (1-indexed)
    def current_page
      [ params[:page].to_i, 1 ].max
    end

    # Calculate total number of pages
    def total_pages
      (Calculation.count.to_f / RECORDS_PER_PAGE).ceil
    end

    # Calculate offset for pagination
    def pagination_offset
      (current_page - 1) * RECORDS_PER_PAGE
    end

    # Get sort column from params (whitelisted)
    def sort_column
      %w[date bill_amount tip_percentage].include?(params[:sort]) ? params[:sort] : "date"
    end

    # Get sort direction from params (whitelisted)
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction].to_sym : :desc
    end
  end
end
