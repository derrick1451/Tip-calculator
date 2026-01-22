# frozen_string_literal: true

require "test_helper"

class CalculationsControllerTest < ActionDispatch::IntegrationTest
  # ============================================
  # GET /calculations/new (Root path)
  # ============================================

  test "should get new" do
    get new_calculation_url
    assert_response :success
    assert_select "h1", /SPLI/
  end

  test "new page contains calculator form" do
    get new_calculation_url
    assert_response :success
    assert_select "form"
    assert_select "input[name='calculation[bill_amount]']"
    assert_select "input[name='calculation[tip_percentage]']"
    assert_select "input[name='calculation[people_count]']"
  end

  test "new page contains tip preset buttons" do
    get new_calculation_url
    assert_response :success
    assert_select "button[data-tip='5']"
    assert_select "button[data-tip='10']"
    assert_select "button[data-tip='15']"
    assert_select "button[data-tip='25']"
    assert_select "button[data-tip='50']"
  end

  # ============================================
  # POST /calculations
  # ============================================

  test "should create calculation with valid params" do
    assert_difference("Calculation.count") do
      post calculations_url, params: {
        calculation: {
          bill_amount: 100.00,
          tip_percentage: 15.00,
          people_count: 2
        }
      }
    end

    assert_response :success
  end

  test "create calculates tip correctly" do
    post calculations_url, params: {
      calculation: {
        bill_amount: 100.00,
        tip_percentage: 20.00,
        people_count: 1
      }
    }

    calculation = Calculation.last
    assert_equal 20.00, calculation.tip_amount
    assert_equal 120.00, calculation.total_amount
    assert_equal 120.00, calculation.per_person_amount
  end

  test "create calculates per person amount correctly" do
    post calculations_url, params: {
      calculation: {
        bill_amount: 100.00,
        tip_percentage: 20.00,
        people_count: 4
      }
    }

    calculation = Calculation.last
    assert_equal 30.00, calculation.per_person_amount
  end

  test "create handles decimal bill amounts" do
    post calculations_url, params: {
      calculation: {
        bill_amount: 87.53,
        tip_percentage: 18.00,
        people_count: 3
      }
    }

    assert_response :success
    calculation = Calculation.last
    assert_in_delta 15.75, calculation.tip_amount, 0.01
    assert_in_delta 103.28, calculation.total_amount, 0.01
  end

  test "create fails with invalid bill amount" do
    assert_no_difference("Calculation.count") do
      post calculations_url, params: {
        calculation: {
          bill_amount: -10.00,
          tip_percentage: 15.00,
          people_count: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create fails with invalid people count" do
    assert_no_difference("Calculation.count") do
      post calculations_url, params: {
        calculation: {
          bill_amount: 100.00,
          tip_percentage: 15.00,
          people_count: 0
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create fails with tip percentage over 100" do
    assert_no_difference("Calculation.count") do
      post calculations_url, params: {
        calculation: {
          bill_amount: 100.00,
          tip_percentage: 150.00,
          people_count: 1
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # ============================================
  # JSON API Tests
  # ============================================

  test "create returns JSON response when requested" do
    post calculations_url, params: {
      calculation: {
        bill_amount: 50.00,
        tip_percentage: 10.00,
        people_count: 2
      }
    }, as: :json

    assert_response :created
    json_response = JSON.parse(response.body)

    assert_equal 50.0, json_response["bill_amount"]
    assert_equal 10.0, json_response["tip_percentage"]
    assert_equal 5.0, json_response["tip_amount"]
    assert_equal 55.0, json_response["total_amount"]
    assert_equal 2, json_response["people_count"]
    assert_equal 27.5, json_response["per_person_amount"]
  end

  test "create returns JSON errors for invalid params" do
    post calculations_url, params: {
      calculation: {
        bill_amount: -100.00,
        tip_percentage: 15.00,
        people_count: 1
      }
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].present?
  end
end
