class Calculation < ApplicationRecord
  # Validations
  validates :bill_amount, presence: true, numericality: { greater_than: 0 }
  validates :tip_percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :tip_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :people_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :per_person_amount, presence: true, numericality: { greater_than: 0 }

  # Scopes for sorting
  scope :by_date, ->(direction = :desc) { order(created_at: direction) }
  scope :by_bill_amount, ->(direction = :desc) { order(bill_amount: direction) }
  scope :by_tip_percentage, ->(direction = :desc) { order(tip_percentage: direction) }

  # Class methods for statistics
  def self.total_count
    count
  end

  def self.average_tip_percentage
    average(:tip_percentage)&.round(2) || 0
  end

  def self.average_bill_amount
    average(:bill_amount)&.round(2) || 0
  end

  def self.total_tips_collected
    sum(:tip_amount)&.round(2) || 0
  end

  def self.average_party_size
    average(:people_count)&.round(1) || 0
  end

  # Instance method to calculate values before save
  def calculate!
    self.tip_amount = (bill_amount * tip_percentage / 100).round(2)
    self.total_amount = (bill_amount + tip_amount).round(2)
    self.per_person_amount = (total_amount / people_count).round(2)
    self
  end
end
