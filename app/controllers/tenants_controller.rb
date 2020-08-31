class TenantsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_tenant, only: [:edit, :show, :update, :destroy]

  def show
    authorize @tenant
    @waters = policy_scope(Water.where("statut = ? AND tenant_id = ?", "active", @tenant.id ).order(submission_date: :asc))
    # @rents = policy_scope(Rent.where("statut = ? AND tenant_id = ?", "active", @tenant.id ).order(period: :asc))
    if params[:search] == nil
      @rents_unorder = Rent.search_by_date(Date.today.year)
      @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id}.sort_by { |b| b.period }
    else
      @rents_unorder = Rent.search_by_date(params[:search][:date].to_i)
      @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id}.sort_by { |b| b.period }
    end
  end

  def new
    authorize @tenant = Tenant.new
    @apartment = Apartment.find(params[:apartment_id])
  end

  def create
    authorize @tenant = Tenant.new(tenant_params)
    @apartment = Apartment.find(params[:apartment_id])
    @tenant.apartment = @apartment
    @tenant.user_id = current_user.id
    @tenant.statut = "active"
    if @tenant.save
      redirect_to apartment_path(@apartment)
    else
      render :new
    end
  end

  def edit
    authorize @tenant
  end

  def update
    authorize @tenant
    if @tenant.update(tenant_params)
      redirect_to apartment_path(@tenant.apartment)
    else
      render :edit
    end
  end

  def destroy
    authorize @tenant
    @tenant.statut = "deleted"
    @tenant.save
    redirect_to apartment_path(@tenant.apartment)
  end

  def search_by_date

  end

  private

  def tenant_params
    params.require(:tenant).permit(
      :submission_date,
      :quantity,
      :photo
    )
  end

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

end
