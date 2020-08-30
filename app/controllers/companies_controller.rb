class CompaniesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_company, only: [:edit, :show, :update, :destroy]

  def index
    @companies = policy_scope(Company.where("statut = ?", "active" ).order(created_at: :asc))
  end

  def show
    authorize @company
    @buildings = policy_scope(Building.where("statut = ? AND company_id = ?", "active", @company.id ).order(created_at: :asc))
  end

  def new
    authorize @company = Company.new
  end

  def create
    authorize @company = Company.new(company_params)
    @company.user_id = current_user.id
    @company.statut = "active"
    if @company.save
      redirect_to companies_path
    else
      render :new
    end
  end

  def edit
    authorize @company
  end

  def update
    authorize @company
    if @company.update(company_params)
      redirect_to companies_path
    else
      render :edit
    end
  end

  def destroy
    authorize @company
    @company.statut = "deleted"
    @company.save
    redirect_to companies_path
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :address,
      :corporate_tax,
      :vat,
      :associe
    )
  end

  def set_company
    @company = Company.find(params[:id])
  end

end
