# frozen_string_literal: true

require "test_helper"

class CalculationTest < ActiveSupport::TestCase
  # Valid calculation for testing
  def valid_calculation
    Calculation.new(
      bill_amount: 100.00,
      tip_percentage: 15.00,
      tip_amount: 15.00,
      total_amount: 115.00,
      people_count: 2,
      per_person_amount: 57.50
    )
  end

  # ============================================
  # Validation Tests
  # ============================================

  test "valid calculation is valid" do
    calculation = valid_calculation
    assert calculation.valid?
  end

  test "bill_amount is required" do
    calculation = valid_calculation
    calculation.bill_amount = nil
    assert_not calculation.valid?
    assert_includes calculation.errors[:bill_amount], "can't be blank"
  end

  test "bill_amount must be positive" do
    calculation = valid_calculation
    calculation.bill_amount = 0
    assert_not calculation.valid?
    assert_includes calculation.errors[:bill_amount], "must be greater than 0"

    calculation.bill_amount = -10
    assert_not calculation.valid?
  end

  test "tip_percentage is required" do
    calculation = valid_calculation
    calculation.tip_percentage = nil
    assert_not calculation.valid?
    assert_includes calculation.errors[:tip_percentage], "can't be blank"
  end

  test "tip_percentage must be between 0 and 100" do
    calculation = valid_calculation

    calculation.tip_percentage = -1
    assert_not calculation.valid?

    calculation.tip_percentage = 0
    assert calculation.valid?

    calculation.tip_percentage = 100
    assert calculation.valid?

    calculation.tip_percentage = 101
    assert_not calculation.valid?
  end

  test "tip_amount is required" do
    calculation = valid_calculation
    calculation.tip_amount = nil
    assert_not calculation.valid?
  end

  test "total_amount is required" do
    calculation = valid_calculation
    calculation.total_amount = nil
    assert_not calculation.valid?
  end

  test "people_count is required" do
    calculation = valid_calculation
    calculation.people_count = nil
    assert_not calculation.valid?
  end

  test "people_count must be a positive integer" do
    calculation = valid_calculation

    calculation.people_count = 0
    assert_not calculation.valid?

    calculation.people_count = -1
    assert_not calculation.valid?

    calculation.people_count = 1.5
    assert_not calculation.valid?

    calculation.people_count = 1
    assert calculation.valid?
  end

  test "per_person_amount is required" do
    calculation = valid_calculation
    calculation.per_person_amount = nil
    assert_not calculation.valid?
  end

  # ============================================
  # Calculation Method Tests
  # ============================================

  test "calculate! computes tip_amount correctly" do
    calculation = Calculation.new(
      bill_amount: 100.00,
      tip_percentage: 20.00,
      people_count: 1
    )
    calculation.calculate!

    assert_equal 20.00, calculation.tip_amount
  end

  test "calculate! computes total_amount correctly" do
    calculation = Calculation.new(
      bill_amount: 100.00,
      tip_percentage: 15.00,
      people_count: 1
    )
    calculation.calculate!

    assert_equal 115.00, calculation.total_amount
  end

  test "calculate! computes per_person_amount correctly" do
    calculation = Calculation.new(
      bill_amount: 100.00,
      tip_percentage: 20.00,
      people_count: 4
    )
    calculation.calculate!

    assert_equal 30.00, calculation.per_person_amount
  end

  test "calculate! rounds to 2 decimal places" do
    calculation = Calculation.new(
      bill_amount: 33.33,
      tip_percentage: 18.00,
      people_count: 3
    )
    calculation.calculate!

    assert_equal 6.00, calculation.tip_amount # 33.33 * 0.18 = 5.9994 -> 6.00
    assert_equal 39.33, calculation.total_amount
    assert_equal 13.11, calculation.per_person_amount
  end

  # ============================================
  # Scope Tests
  # ============================================

  test "by_date scope orders by created_at" do
    # This test requires database records
    Calculation.destroy_all

    old = Calculation.create!(
      bill_amount: 50.00,
      tip_percentage: 10.00,
      tip_amount: 5.00,
      total_amount: 55.00,
      people_count: 1,
      per_person_amount: 55.00,
      created_at: 2.days.ago
    )

    new = Calculation.create!(
      bill_amount: 100.00,
      tip_percentage: 20.00,
      tip_amount: 20.00,
      total_amount: 120.00,
      people_count: 1,
      per_person_amount: 120.00,
      created_at: 1.day.ago
    )

    assert_equal [ new, old ], Calculation.by_date(:desc).to_a
    assert_equal [ old, new ], Calculation.by_date(:asc).to_a
  end

  test "by_bill_amount scope orders by bill_amount" do
    Calculation.destroy_all

    small = Calculation.create!(
      bill_amount: 25.00,
      tip_percentage: 15.00,
      tip_amount: 3.75,
      total_amount: 28.75,
      people_count: 1,
      per_person_amount: 28.75
    )

    large = Calculation.create!(
      bill_amount: 200.00,
      tip_percentage: 15.00,
      tip_amount: 30.00,
      total_amount: 230.00,
      people_count: 1,
      per_person_amount: 230.00
    )

    assert_equal [ large, small ], Calculation.by_bill_amount(:desc).to_a
    assert_equal [ small, large ], Calculation.by_bill_amount(:asc).to_a
  end

  # ============================================
  # Statistics Tests
  # ============================================

  test "average_tip_percentage returns correct average" do
    Calculation.destroy_all

    Calculation.create!(
      bill_amount: 100.00,
      tip_percentage: 10.00,
      tip_amount: 10.00,
      total_amount: 110.00,
      people_count: 1,
      per_person_amount: 110.00
    )

    Calculation.create!(
      bill_amount: 100.00,
      tip_percentage: 20.00,
      tip_amount: 20.00,
      total_amount: 120.00,
      people_count: 1,
      per_person_amount: 120.00
    )

    assert_equal 15.0, Calculation.average_tip_percentage
  end

  test "total_count returns correct count" do
    Calculation.destroy_all

    assert_equal 0, Calculation.total_count

    Calculation.create!(
      bill_amount: 100.00,
      tip_percentage: 15.00,
      tip_amount: 15.00,
      total_amount: 115.00,
      people_count: 1,
      per_person_amount: 115.00
    )

    assert_equal 1, Calculation.total_count
  end

  test "total_tips_collected returns sum of all tips" do
    Calculation.destroy_all

    Calculation.create!(
      bill_amount: 100.00,
      tip_percentage: 10.00,
      tip_amount: 10.00,
      total_amount: 110.00,
      people_count: 1,
      per_person_amount: 110.00
    )

    Calculation.create!(
      bill_amount: 50.00,
      tip_percentage: 20.00,
      tip_amount: 10.00,
      total_amount: 60.00,
      people_count: 1,
      per_person_amount: 60.00
    )

    assert_equal 20.0, Calculation.total_tips_collected
  end
end

