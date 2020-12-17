class RentsController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_rent, only: [:edit, :show, :update, :destroy]

  def index
    @rents = policy_scope(Rent.where("statut = ?", "active").order(created_at: :asc))
    @tenants = policy_scope(Tenant.where("statut = ?", "active").order(created_at: :asc))
  end

  def show
    authorize @rent
  end

  def new
    if params[:tenant_id] != nil
      authorize @rent = Rent.new
      @tenant = Tenant.find(params[:tenant_id])
    else
      authorize @rent = Rent.new
      # List of companies created by user or where user is an associate
      @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
      @companies_list = []
      @companies_active.each do |c|
        associe = c.associe.downcase.split(",").map(&:strip)
        if associe.include?(current_user.email) || c.user == current_user
          @companies_list << c
        end
      end
      @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
      @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
      @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
      @buildings_list = []
      @apartments_list = []
      @tenants_list = []
      @companies_list.each do |c|
        # List of buildings in companies of user
        @buildings_active.each do |b|
          if b.company_name == c.name
            @buildings_list << b
          end
        end
        # List of apartment in companies of user
        @apartments_active.each do |a|
          if a.company_name == c.name
            @apartments_list << a
          end
        end
        # List of tenants in companies of user
        @tenants_active.each do |t|
          if t.company_name == c.name
            @tenants_list << t
          end
        end
      end
      # List of buildings created by user
      @buildings_active.each do |b|
        if b.user == current_user
          if @buildings_list.include?(b.name) == false
            @buildings_list << b
          end
        end
      end
      # list of apartments created by the user
      @apartments_active.each do |a|
        if a.user == current_user
          if @apartments_list.include?(a) == false
            @apartments_list << a
          end
        end
      end
      # list of tenants created by the user
      @tenants_active.each do |t|
        if t.user == current_user
          if @tenants_list.include?(t) == false
            @tenants_list << t
          end
        end
      end
      @buildings_list.each do |b|
        # List of appartements in buildings of user
        @apartments_active.each do |a|
          if a.building_name == b.name
            if @apartments_list.include?(a) == false
              @apartments_list << a
            end
          end
        end
        # List of tenants in buildings of user
        @tenants_active.each do |t|
          if t.building_name == b.name
            if @tenants_list.include?(t) == false
              @tenants_list << t
            end
          end
        end
      end
      # List of tenant in apartment of user
      @apartments_list.each do |a|
        @tenants_active.each do |t|
          if t.building_name == a.name
            if @tenants_list.include?(t) == false
              @tenants_list << t
            end
          end
        end
      end
      @tenants = @tenants_list.sort_by { |b| b.last_name }
    end
  end

  def create
    authorize @rent = Rent.new(rent_params)
    # @tenant = Tenant.find(params[:tenant_id])
    # @rent.tenant = Tenant.find(params[:s])
    @rent.user_id = current_user.id
    @rent.statut = "active"
    if @rent.save
      redirect_to rents_path
    else
      render :new
    end
  end

  def edit
    authorize @rent
  end

  def update
    authorize @rent
    if @rent.update(rent_params)
      redirect_to apartment_tenants_path(@rent.tenant.apartment)
    else
      render :edit
    end
  end

  def destroy
    authorize @rent
    @rent.statut = "deleted"
    @rent.save
    redirect_to apartment_tenants_path(@rent.tenant.apartment)
  end

  private

  def rent_params
    params.require(:rent).permit(
      :period,
      :rent_ask,
      :service_charge_ask,
      :rent_paid,
      :service_charge_paid,
      :date_payment,
      :tenant_id
    )
  end

  def set_rent
    @rent = Rent.find(params[:id])
  end
end
