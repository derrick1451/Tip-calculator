# frozen_string_literal: true

class CalculationsController < ApplicationController
  # GET / or GET /calculations/new
  # Display the tip calculator form
  def new
    @calculation = Calculation.new
  end

  # POST /calculations
  # Save the calculation to the database and return results
  def create
    @calculation = Calculation.new(calculation_params)

    # Perform the calculation
    @calculation.calculate!

    respond_to do |format|
      if @calculation.save
        format.html { render :result }
        format.json { render json: calculation_result_json, status: :created }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("calculation-result", partial: "calculations/result", locals: { calculation: @calculation }) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { errors: @calculation.errors.full_messages }, status: :unprocessable_entity }
        format.turbo_stream { render turbo_stream: turbo_stream.replace("calculation-form", partial: "calculations/form", locals: { calculation: @calculation }) }
      end
    end
  end

  private

  # Strong parameters for calculation
  def calculation_params
    params.require(:calculation).permit(:bill_amount, :tip_percentage, :people_count)
  end

  # JSON response for API/AJAX requests
  def calculation_result_json
    {
      id: @calculation.id,
      bill_amount: @calculation.bill_amount.to_f,
      tip_percentage: @calculation.tip_percentage.to_f,
      tip_amount: @calculation.tip_amount.to_f,
      total_amount: @calculation.total_amount.to_f,
      people_count: @calculation.people_count,
      per_person_amount: @calculation.per_person_amount.to_f,
      created_at: @calculation.created_at
    }
  end
end
