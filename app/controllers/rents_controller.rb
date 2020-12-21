class RentsController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_rent, only: [:edit, :show, :update, :destroy]

  def index
    @years = [Date.today.year-3, Date.today.year-2, Date.today.year-1, Date.today.year, Date.today.year+1, Date.today.year+2]
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
    # Sort tenant list by alphabetic order
    @tenants = @tenants_list.sort_by { |b| b.last_name }
    @tenants_array = ["Tous les locataires"]
    @tenants.each do |t|
      @tenants_array << t.name
    end
    # -----------------------------------------------
    @rents_active = Rent.where("statut = ?", "active" ).order(created_at: :asc)
    # If params is nil
    if params[:search] == nil
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = []
      # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      @tenants.each do |t|
        @rents_active.each do |r|
          if r.name == t.name
            @rents_list_unsorted << r
          end
        end
      end
      @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      @rents_list = []
      @rents_sorted.each do |r|
        if r.period.strftime("%Y").to_i == Date.today.year
          @rents_list << r
        end
      end
      # if params = tous les locataires
    elsif params[:search][:tenant] == "Tous les locataires"
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = []
      # @rents = policy_scope(Rent.where("statut = ?", "active").order("name ASC, period ASC"))
      @tenants.each do |t|
        @rents_active.each do |r|
          if r.name == t.name
            @rents_list_unsorted << r
          end
        end
      end
      @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      @rents_list = []
      @rents_sorted.each do |r|
        if r.period.strftime("%Y") == params[:search][:year]
          @rents_list << r
        end
      end

    else
      @rents = policy_scope(Rent.all)
      @rents_list_unsorted = policy_scope(Rent.search_by_tenant(params[:search][:tenant]))
      @rents_sorted = @rents_list_unsorted.sort_by { |b| [b.name, b.period] }
      @rents_list = []
      @rents_sorted.each do |r|
        if r.period.strftime("%Y") == params[:search][:year]
          @rents_list << r
        end
      end
    end
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
    @rent.name = Tenant.find(@rent.tenant_id).name
    @rent.statut = "active"
    if @rent.save
      redirect_to rents_path
    else
      render :new
    end
  end

  def edit
    if params[:tenant_id] != nil
      authorize @rent
      @tenant = Tenant.find(params[:tenant_id])
    else
      authorize @rent
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

  def update
    authorize @rent
    @rent.name = Tenant.find(params[:rent][:tenant_id]).name
    if @rent.update(rent_params)
      redirect_to rents_path
    else
      render :edit
    end
  end

  def destroy
    authorize @rent
    @rent.statut = "deleted"
    @rent.save
    redirect_to rents_path
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
