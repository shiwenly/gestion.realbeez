class ExpensesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_expense, only: [:edit, :show, :update, :destroy]

  def show
    authorize @expense
  end

  def new
    authorize @expense = Expense.new
    @building = Building.find(params[:building_id])
    @apartment_name = ["Tous"]
    @apartments_name = @building.apartments.each do |apartment|
      @apartment_name  << apartment.name.to_s
    end
  end

  def create
    authorize @expense = Expense.new(expense_params)
    @building = Building.find(params[:building_id])
    @expense.building = @building
    @expense.user_id = current_user.id
    @expense.statut = "active"
    if @expense.save
      redirect_to building_path(@building)
    else
      render :new
    end
  end

  def edit
    authorize @expense
    # @building = @expense.building
    # @apartment_name = []
    # @apartments_name = @building.apartments.each do |apartment|
    #   @apartment_name  << apartment.name
    # end
  end

  def update
    authorize @expense
    if @expense.update(expense_params)
      redirect_to building_path(@expense.building)
    else
      render :edit
    end
  end

  def destroy
    authorize @expense
    @expense.statut = "deleted"
    @expense.save
    redirect_to building_path(@expense.building)
  end

  private

  def expense_params
    params.require(:expense).permit(
      :apartment_name,
      :expense_type,
      :date,
      :supplier,
      :amount_ttc,
      :amount_vat,
      :photo,
      :deductible
    )
  end

  def set_expense
    @expense = Expense.find(params[:id])
  end

end
