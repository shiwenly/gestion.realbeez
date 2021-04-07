class TenantsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_tenant, only: [:edit, :update, :destroy]

  def index
    if params[:apartment_id] != nil
      authorize @apartment = Apartment.find(params[:apartment_id])
      @tenants_list = policy_scope(Tenant.where("statut = ? AND apartment_id = ?", "active", @apartment.id ).order(name: :asc))
      @rents_active = Rent.where("statut = ? AND user_id = ?", "active", current_user.id)
      @rent_ask = @rents_active.select{ |r| r.tenant.apartment_id == @apartment.id && r.date_payment.strftime("%Y").to_i == Date.today.year }.map{ |r| r.rent_ask}.sum
      @service_charge_ask = @rents_active.select{ |r| r.tenant.apartment_id == @apartment.id && r.date_payment.strftime("%Y").to_i == Date.today.year }.map{ |r| r.service_charge_ask}.sum
      @rent_paid = @rents_active.select{ |r| r.tenant.apartment_id == @apartment.id && r.date_payment.strftime("%Y").to_i == Date.today.year }.map{ |r| r.rent_paid}.sum
      @service_charge_paid = @rents_active.select{ |r| r.tenant.apartment_id == @apartment.id && r.date_payment.strftime("%Y").to_i == Date.today.year}.map{ |r| r.service_charge_paid}.sum
      @solde = @rent_ask + @service_charge_ask - @rent_paid - @service_charge_paid
      @tenants = policy_scope(Tenant.where("statut = ? AND apartment_id = ?", "active", @apartment.id ).order(created_at: :desc))
    else
      # -------------- Paramters for Filter --------------
      authorize @buildings = policy_scope(Building.where("statut = ?", "active" ).order(created_at: :asc))
      @companies_active = Company.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      @buildings_active = Building.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      @apartments_active = Apartment.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      @tenants_active = Tenant.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
      @companies_array = ["Toutes les sociétés", "n/a - détention en nom propre"]
      @companies = []
      @companies_active.each do |c|
        # associe = c.associe.downcase.split(",").map(&:strip)
        # if associe.include?(current_user.email) || c.user == current_user
        #   @companies << c
        #   @companies_array << c.name
        # end
        @companies << c
        @companies_array << c.name
      end
      @buildings_array = ["Tous les immeubles", "n/a - aucun immeuble"]
      @buildings = []
      @apartments = @apartments_active
      if params[:search] == nil || params[:search][:company] == "Toutes les sociétés"
        # Companies and Buildings list for filter
        @buildings_active.each do |b|
          # if b.company_name == c.name
          #   @buildings_array << b.name
          #   @buildings << b
          # end
          @buildings_array << b.name
          @buildings << b
        end
        # @buildings_active.each do |b|
        #   if b.user == current_user
        #     if @buildings_array.include?(b.name) == false
        #       @buildings_array << b.name
        #       @buildings << b
        #     end
        #   end
        # end
      else
        @buildings_active.each do |b|
          if b.company_name == params[:search][:company]
            @buildings_array << b.name
            @buildings << b
          end
        end
      end
      # ------------ Result of selection -------------
      if params[:search] == nil || params[:search][:company] == "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
        @tenants_list = Tenant.where("statut = ? AND user_id = ?", "active", current_user.id ).order(created_at: :asc)
        # List of companies created by user or where user is an associate
        # @companies_list = []
        # @companies_active.each do |c|
        #   associe = c.associe.downcase.split(",").map(&:strip)
        #   if associe.include?(current_user.email) || c.user == current_user
        #     @companies_list << c
        #   end
        # end
        # @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
        # @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
        # @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
        # @buildings_list = []
        # @apartments_list = []
        # @tenants_list = []
        # @companies_list.each do |c|
        #   # List of buildings in companies of user
        #   @buildings_active.each do |b|
        #     if b.company_name == c.name
        #       @buildings_list << b
        #     end
        #   end
        #   # List of apartment in companies of user
        #   @apartments_active.each do |a|
        #     if a.company_name == c.name
        #       @apartments_list << a
        #     end
        #   end
        #   # List of tenants in companies of user
        #   @tenants_active.each do |t|
        #     if t.company_name == c.name
        #       @tenants_list << t
        #     end
        #   end
        # end
        # # List of buildings created by user
        # @buildings_active.each do |b|
        #   if b.user == current_user
        #     if @buildings_list.include?(b.name) == false
        #       @buildings_list << b
        #     end
        #   end
        # end
        # # list of apartments created by the user
        # @apartments_active.each do |a|
        #   if a.user == current_user
        #     if @apartments_list.include?(a) == false
        #       @apartments_list << a
        #     end
        #   end
        # end
        # # list of tenants created by the user
        # @tenants_active.each do |t|
        #   if t.user == current_user
        #     if @tenants_list.include?(t) == false
        #       @tenants_list << t
        #     end
        #   end
        # end
        # @buildings_list.each do |b|
        #   # List of appartements in buildings of user
        #   @apartments_active.each do |a|
        #     if a.building_name == b.name
        #       if @apartments_list.include?(a) == false
        #         @apartments_list << a
        #       end
        #     end
        #   end
        #   # List of tenants in buildings of user
        #   @tenants_active.each do |t|
        #     if t.building_name == b.name
        #       if @tenants_list.include?(t) == false
        #         @tenants_list << t
        #       end
        #     end
        #   end
        # end
        # # List of tenant in apartment of user
        # @apartments_list.each do |a|
        #   @tenants_active.each do |t|
        #     if t.building_name == a.name
        #       if @tenants_list.include?(t) == false
        #         @tenants_list << t
        #       end
        #     end
        #   end
        # end
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "Tous les immeubles"
        @tenants_list = @tenants_active.select{ |t| t.company_name == params[:search][:company] && t.user_id == current_user.id }
      elsif params[:search][:company] != "Toutes les sociétés" && params[:search][:building] == "n/a - aucun immeuble"
        # @tenants_active = Tenant.where("statut = ?", "active" ).order(created_at: :asc)
        @tenants_list = @tenants_active.select{ |t| t.company_name == params[:search][:company] && t.building_name == "n/a - aucun immeuble" && t.user_id == current_user.id}
      else
        authorize @tenants = Tenant.search_by_building(params[:search][:building])
        @tenants_list = []
        @tenants.each do |t|
          if t.statut == "active" && t.user_id == current_user.id
            @tenants_list << t
          end
        end
      end
      @tenants_list = @tenants_list.sort_by{ |t| t.last_name}
    end
  end

  # def show
  #   authorize @tenant
  #   @waters = policy_scope(Water.where("statut = ? AND tenant_id = ?", "active", @tenant.id ).order(submission_date: :desc).limit(10))
  #   # @rents = policy_scope(Rent.where("statut = ? AND tenant_id = ?", "active", @tenant.id ).order(period: :asc))
  #   if params[:search] == nil
  #     @rents_unorder = Rent.search_by_date(Date.today.year)
  #     @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id}.sort_by { |b| b.period }
  #     @sum_rent_ask = @rents.map{|a| a.rent_ask}.sum
  #     @sum_service_charge_ask = @rents.map{|a| a.service_charge_ask }.sum
  #     @sum_rent_paid = @rents.map{|a| a.rent_paid}.sum
  #     @sum_service_charge_paid = @rents.map{|a| a.service_charge_paid }.sum
  #     @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
  #   else
  #     @rents_unorder = Rent.search_by_date(params[:search][:date].to_i)
  #     @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id}.sort_by { |b| b.period }
  #     @sum_rent_ask = @rents.map{|a| a.rent_ask}.sum
  #     @sum_service_charge_ask = @rents.map{|a| a.service_charge_ask }.sum
  #     @sum_rent_paid = @rents.map{|a| a.rent_paid}.sum
  #     @sum_service_charge_paid = @rents.map{|a| a.service_charge_paid }.sum
  #     @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
  #   end
  # end

  def new
    if params[:apartment_id] != nil
      authorize @tenant = Tenant.new
      @apartment = Apartment.find(params[:apartment_id])
    else
      authorize @tenant = Tenant.new
      # List of companies of the user and where user is an associate
      @companies = Company.where("user_id = ? AND statut = ?", current_user.id, "active" ).order(created_at: :asc)
      # @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
      # @companies_active.each do |c|
      #   associe = c.associe.downcase.split(",").map(&:strip)
      #   if associe.include?(current_user.email) || c.user == current_user
      #     @companies << c
      #   end
      # end
      # List of buildings détenu en nom propre
      @buildings_nom_propre = Building.where("statut = ? AND user_id = ? AND company_name = ?", "active", current_user.id, "n/a - détention en nom propre" ).order(created_at: :asc)
      @buildings = ["n/a - aucun immeuble"]
      # @companies.each do |c|
      @buildings_nom_propre.each do |b|
        # if @buildings.include?(b) == false
        # if b.company_name == "n/a - détention en nom propre"
        @buildings << b.name
        # end
        # end
      end
      # end
      # List of apartment détenu en nom propre in aucun immeuble
      @apartments= Apartment.where("statut = ? AND building_name = ? AND company_name = ? AND user_id = ?", "active","n/a - aucun immeuble", "n/a - détention en nom propre", current_user.id ).order(created_at: :asc)
      # @apartments = []
      # @apartments_active.each do |a|
      #   if @apartments.include?(a) == false
      #     if a.building_name == "n/a - aucun immeuble" && a.company_name == "n/a - détention en nom propre"
      #       @apartments << a
      #     end
      #   end
      # end
    end
  end

  def create
    authorize @tenant = Tenant.new(tenant_params)
    if params[:apartment_id] != nil
      @apartment = Apartment.find(params[:apartment_id])
      @tenant.apartment_id = @apartment.id
      @tenant.apartment_name = @apartment.name
      @tenant.building_id = @apartment.building_id
      @tenant.building_name = @apartment.building_name
      @tenant.company_id = @apartment.company_id
      @tenant.company_name = @apartment.company_name
      @tenant.user_id = current_user.id
      @tenant.name = "#{@tenant.first_name.strip} #{@tenant.last_name.strip}"
      @tenant.statut = "active"
      @tenant.current_tenant = true
      if @tenant.save
        redirect_to apartment_tenants_path(@apartment)
      else
        render :new
      end
    else
      if @tenant.apartment_id != nil
        @tenant.apartment_name = Apartment.find(@tenant.apartment_id).name
        unless Apartment.find(@tenant.apartment_id).building_id == nil || Apartment.find(@tenant.apartment_id).building_id == "" || Apartment.find(@tenant.apartment_id).building_id == 0
          @tenant.building_name = Building.find(Apartment.find(@tenant.apartment_id).building_id).name
          @tenant.building_id = Building.find(Apartment.find(@tenant.apartment_id).building_id).id
        else
          @tenant.building_name = "n/a - aucun immeuble"
          @tenant.building_id = nil
        end
        unless Apartment.find(@tenant.apartment_id).company_id == nil || Apartment.find(@tenant.apartment_id).company_id == "" || Apartment.find(@tenant.apartment_id).company_id == 0
          @tenant.company_name = Company.find(Apartment.find(@tenant.apartment_id).company_id).name
          @tenant.company_id = Company.find(Apartment.find(@tenant.apartment_id).company_id).id
        else
          @tenant.company_name = "n/a - détention en nom propre"
          @tenant.company_id = nil
        end
      end
      @tenant.user_id = current_user.id
      @tenant.name = "#{@tenant.first_name.strip} #{@tenant.last_name.strip}"
      @tenant.statut = "active"
      @tenant.current_tenant = true
      if @tenant.save
        redirect_to tenants_path
      else
        render :new
      end
    end
  end

  def edit
    authorize @tenant
    # List of companies of the user and where user is an associate
    @companies = Company.where("user_id = ? AND statut = ?", current_user.id, "active" ).order(created_at: :asc)
    # @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
    # @companies_active.each do |c|
    #   associe = c.associe.downcase.split(",").map(&:strip)
    #   if associe.include?(current_user.email) || c.user == current_user
    #     @companies << c
    #   end
    # end
    # List of buildings détenu en nom propre
    @buildings = Building.where("statut = ? AND user_id = ? AND company_name =?", "active", current_user.id, @tenant.company_name  ).order(created_at: :asc)
    # @buildings_active = Building.where("statut = ?", "active" ).order(created_at: :asc)
    # @companies.each do |c|
    # @buildings_active.each do |b|
    #   if @buildings.include?(b) == false
    #     if b.company_name == @tenant.company_name
    #       @buildings << b
    #     end
    #   end
    # end
    # end
    # List of apartment détenu en nom propre in aucun immeuble
    @apartments = Apartment.where("statut = ? AND user_id = ? AND building_name = ? AND company_name = ?", "active", current_user.id, @tenant.building_name, @tenant.company_name ).order(created_at: :asc)
    # @apartments_active = Apartment.where("statut = ?", "active" ).order(created_at: :asc)
    # @buildings.each do |c|
    # @apartments_active.each do |a|
    #   if @apartments.include?(a) == false
    #     if a.building_name == @tenant.building_name && a.company_name == @tenant.company_name
    #       @apartments << a
    #     end
    #   end
    # end
    # end
    # @buildings << "n/a - aucun immeuble"
  end

  def update
    authorize @tenant
    @tenant.apartment_name = Apartment.find(params[:tenant][:apartment_id]).name
    unless Apartment.find(params[:tenant][:apartment_id]).building_id == nil || Apartment.find(params[:tenant][:apartment_id]).building_id == "" || Apartment.find(params[:tenant][:apartment_id]).building_id == 0
      @tenant.building_name = Building.find(Apartment.find(params[:tenant][:apartment_id]).building_id).name
      @tenant.building_id = Building.find(Apartment.find(params[:tenant][:apartment_id]).building_id).id
    else
      @tenant.building_name = "n/a - aucun immeuble"
      @tenant.building_id = nil
    end
    unless Apartment.find(params[:tenant][:apartment_id]).company_id == nil || Apartment.find(params[:tenant][:apartment_id]).company_id == "" || Apartment.find(params[:tenant][:apartment_id]).company_id == 0
      @tenant.company_name = Company.find(Apartment.find(params[:tenant][:apartment_id]).company_id).name
      @tenant.company_id = Company.find(Apartment.find(params[:tenant][:apartment_id]).company_id).id
    else
      @tenant.company_name = "n/a - détention en nom propre"
      @tenant.company_id = nil
    end
    @tenant.name = "#{params[:tenant][:first_name].strip} #{params[:tenant][:last_name].strip}"
    if @tenant.update(tenant_params)
      # Change name
      @rents = @tenant.rents
      @rents.each do |r|
        r.name = @tenant.name
        r.save
      end
      redirect_to tenants_path
    else
      render :edit
    end
  end

  def destroy
    authorize @tenant
    @tenant.statut = "deleted"
    @tenant.save
    @rents = @tenant.rents
    @rents.each do |r|
      r.statut = "deleted"
      r.save
    end
    redirect_to tenants_path
  end

  def search_by_date

  end

  private

  def tenant_params
    params.require(:tenant).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :rent,
      :service_charge,
      :deposit,
      :contract,
      :inventory,
      :move_in_date,
      :move_out_date,
      :current_tenant,
      :apartment_id
    )
  end

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

end
