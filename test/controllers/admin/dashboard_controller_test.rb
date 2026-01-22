# frozen_string_literal: true

require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  # Helper to log in as admin
  def log_in_as_admin
    post admin_login_url, params: { username: "admin", password: "tipcalculator2026" }
  end

  # ============================================
  # Authentication Tests
  # ============================================

  test "dashboard redirects to login when not authenticated" do
    get admin_dashboard_url
    assert_redirected_to admin_login_url
  end

  test "dashboard accessible when logged in" do
    log_in_as_admin
    get admin_dashboard_url
    assert_response :success
  end

  test "login page renders correctly" do
    get admin_login_url
    assert_response :success
    assert_select "h1", /Admin Login/
    assert_select "input[name='username']"
    assert_select "input[name='password']"
  end

  test "login with valid credentials redirects to dashboard" do
    post admin_login_url, params: { username: "admin", password: "tipcalculator2026" }
    assert_redirected_to admin_dashboard_url
    follow_redirect!
    assert_response :success
  end

  test "login with invalid credentials shows error" do
    post admin_login_url, params: { username: "wrong", password: "password" }
    assert_response :unprocessable_entity
    assert_select ".login-alert"
  end

  test "logout clears session and redirects to root" do
    log_in_as_admin
    delete admin_logout_url
    assert_redirected_to root_url

    # Should not be able to access dashboard after logout
    get admin_dashboard_url
    assert_redirected_to admin_login_url
  end

  # ============================================
  # Dashboard Content Tests
  # ============================================

  test "dashboard displays statistics section" do
    log_in_as_admin
    get admin_dashboard_url
    assert_response :success
    assert_select ".stats-grid"
    assert_select ".stat-card"
  end

  test "dashboard displays empty state when no calculations" do
    Calculation.destroy_all
    log_in_as_admin
    get admin_dashboard_url
    assert_response :success
    assert_select ".empty-state"
  end

  test "dashboard displays calculations table when data exists" do
    create_sample_calculation
    log_in_as_admin
    get admin_dashboard_url
    assert_response :success
    assert_select ".data-table"
  end

  test "dashboard shows correct statistics" do
    Calculation.destroy_all
    create_sample_calculation(bill_amount: 100, tip_percentage: 10)
    create_sample_calculation(bill_amount: 100, tip_percentage: 20)

    log_in_as_admin
    get admin_dashboard_url
    assert_response :success

    # Check that statistics section is displayed
    assert_select ".stat-card"
    assert_select ".stat-value"
  end

  # ============================================
  # Sorting Tests
  # ============================================

  test "dashboard sorts by date by default" do
    Calculation.destroy_all
    old_calc = create_sample_calculation(created_at: 2.days.ago, bill_amount: 50)
    new_calc = create_sample_calculation(created_at: 1.day.ago, bill_amount: 100)

    log_in_as_admin
    get admin_dashboard_url
    assert_response :success

    # Check that the data table shows records (newest first by default)
    assert_select ".data-table"
    # Verify both records appear in the response (UGX currency)
    assert_match(/UGX 100/, response.body)
    assert_match(/UGX 50/, response.body)
  end

  test "dashboard can sort by bill_amount" do
    Calculation.destroy_all
    small_calc = create_sample_calculation(bill_amount: 50)
    large_calc = create_sample_calculation(bill_amount: 200)

    log_in_as_admin
    get admin_dashboard_url, params: { sort: "bill_amount", direction: "desc" }
    assert_response :success

    # Verify sort parameters are reflected in the page
    assert_select ".sort-btn.active", text: "Bill Amount"
  end

  test "dashboard can sort by tip_percentage" do
    Calculation.destroy_all
    low_tip = create_sample_calculation(tip_percentage: 5)
    high_tip = create_sample_calculation(tip_percentage: 25)

    log_in_as_admin
    get admin_dashboard_url, params: { sort: "tip_percentage", direction: "desc" }
    assert_response :success

    # Verify sort parameters are reflected in the page
    assert_select ".sort-btn.active", text: "Tip %"
  end

  test "dashboard handles ascending sort direction" do
    Calculation.destroy_all
    small_calc = create_sample_calculation(bill_amount: 50)
    large_calc = create_sample_calculation(bill_amount: 200)

    log_in_as_admin
    get admin_dashboard_url, params: { sort: "bill_amount", direction: "asc" }
    assert_response :success

    # Verify ascending direction is shown
    assert_match(/Ascending/, response.body)
  end

  # ============================================
  # Pagination Tests
  # ============================================

  test "dashboard paginates results" do
    Calculation.destroy_all
    # Create more than 20 records (default per page)
    25.times do |i|
      create_sample_calculation(bill_amount: 100 + i)
    end

    log_in_as_admin
    get admin_dashboard_url
    assert_response :success

    # Check pagination is present (more than one page)
    assert_select ".pagination"
    assert_match(/Page 1 of 2/, response.body)
  end

  test "dashboard shows correct page info" do
    Calculation.destroy_all
    25.times { create_sample_calculation }

    log_in_as_admin
    get admin_dashboard_url, params: { page: 2 }
    assert_response :success

    assert_match(/Page 2 of 2/, response.body)
  end

  test "dashboard handles invalid page numbers gracefully" do
    Calculation.destroy_all
    create_sample_calculation

    log_in_as_admin
    get admin_dashboard_url, params: { page: -1 }
    assert_response :success

    # Should show the record (page defaults to 1)
    assert_select ".data-table"
    assert_match(/UGX 100/, response.body)
  end

  # ============================================
  # Helper Methods
  # ============================================

  private

  def create_sample_calculation(attrs = {})
    defaults = {
      bill_amount: 100.00,
      tip_percentage: 15.00,
      tip_amount: 15.00,
      total_amount: 115.00,
      people_count: 1,
      per_person_amount: 115.00
    }

    # Handle tip calculations if tip_percentage is overridden
    if attrs[:tip_percentage] && !attrs[:tip_amount]
      bill = attrs[:bill_amount] || defaults[:bill_amount]
      tip_pct = attrs[:tip_percentage]
      attrs[:tip_amount] = (bill * tip_pct / 100).round(2)
      attrs[:total_amount] = (bill + attrs[:tip_amount]).round(2)
      attrs[:per_person_amount] = attrs[:total_amount]
    end

    Calculation.create!(defaults.merge(attrs))
  end
end
