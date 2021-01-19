class CompaniesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_company, only: [:edit, :show, :update, :destroy]

  def index
    @companies = policy_scope(Company.where("statut = ?", "active" ).order(created_at: :asc))
    @companies_active = Company.where("statut = ?", "active" ).order(created_at: :asc)
    @companies_list = []
    @companies_active.each do |c|
      associe = c.associe.downcase.split(",").map(&:strip)
      if associe.include?(current_user.email) || c.user == current_user
        @companies_list << c
      end
    end
  end

  def show
    authorize @company
    @buildings = policy_scope(Building.where("statut = ? AND company_id = ?", "active", @company.id ).order(created_at: :asc))

    unless @buildings == []
      @company_building_sum_rent_ask = 0
      @company_building_sum_service_charge_ask = 0
      @company_building_sum_rent_paid = 0
      @company_building_sum_service_charge_paid = 0
      @company_building_solde = 0
      @company_building_loyer_annuel = 0
      @buildings.each do |building|
        unless building.apartments == []
          @building_sum_rent_ask = 0
          @building_sum_service_charge_ask = 0
          @building_sum_rent_paid = 0
          @building_sum_service_charge_paid = 0
          @building_solde = 0
          @building_loyer_annuel = 0
          building.apartments.each do |apartment|
            unless apartment.tenants == []
              @apartment_sum_rent_ask = 0
              @apartment_sum_service_charge_ask = 0
              @apartment_sum_rent_paid = 0
              @apartment_sum_service_charge_paid = 0
              @apartment_solde = 0
              @loyer_annuel = (apartment.tenants.last.rent + apartment.tenants.last.service_charge) *12
              # Calculation
              apartment.tenants.each do |tenant|
                @rents_unorder = Rent.search_by_date(Date.today.year)
                @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.statut == "active" && a.tenant.apartment == apartment && a.tenant.apartment.statut == "active"  && a.tenant.apartment.building == building && a.tenant.apartment.building.company == @company }.sort_by { |b| b.period }
                # @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.apartment == apartment && a.tenant.apartment.building == @building }.sort_by { |b| b.period }
                @sum_rent_ask = @rents.map{|a| a.rent_ask}.sum
                @sum_service_charge_ask = @rents.map{|a| a.service_charge_ask }.sum
                @sum_rent_paid = @rents.map{|a| a.rent_paid}.sum
                @sum_service_charge_paid = @rents.map{|a| a.service_charge_paid }.sum
                @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
                # add to appartment sum
                @apartment_sum_rent_ask += @sum_rent_ask
                @apartment_sum_service_charge_ask += @sum_service_charge_ask
                @apartment_sum_rent_paid += @sum_rent_paid
                @apartment_sum_service_charge_paid += @sum_service_charge_paid
                @apartment_solde += @solde
              end
              @building_sum_rent_ask += @apartment_sum_rent_ask
              @building_sum_service_charge_ask += @apartment_sum_service_charge_ask
              @building_sum_rent_paid += @apartment_sum_rent_paid
              @building_sum_service_charge_paid += @apartment_sum_service_charge_paid
              @building_solde += @apartment_solde
              @building_loyer_annuel += @loyer_annuel
            end
          end
          @company_building_sum_rent_ask += @building_sum_rent_ask
          @company_building_sum_service_charge_ask += @building_sum_service_charge_ask
          @company_building_sum_rent_paid += @building_sum_rent_paid
          @company_building_sum_service_charge_paid += @building_sum_service_charge_paid
          @company_building_solde += @building_solde
          @company_building_loyer_annuel += @building_loyer_annuel
        end
      end
    end


    # unless @buildings == []
    # @company_building_sum_rent_ask = 0
    # @company_building_sum_service_charge_ask = 0
    # @company_building_sum_rent_paid = 0
    # @company_building_sum_service_charge_paid = 0
    # @company_building_solde = 0
    # @company_building_loyer_annuel = 0
    # @buildings.each do |building|
    #     unless building.apartments == []
    #       @building_sum_rent_ask = 0
    #       @building_sum_service_charge_ask = 0
    #       @building_sum_rent_paid = 0
    #       @building_sum_service_charge_paid = 0
    #       @building_solde = 0
    #       @building_loyer_annuel = 0
    #       building.apartments.each do |apartment|
    #         unless apartment.tenants == []
    #           @tenant = apartment.tenants.select { |t| t.current_tenant == true}[0]
    #           @rents_unorder = Rent.search_by_date(Date.today.year)
    # @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == @tenant.id && a.tenant.apartment == apartment && a.tenant.apartment.building == building && a.tenant.apartment.building.company == @company }.sort_by { |b| b.period }
    #           @sum_rent_ask = 0
    #           @sum_service_charge_ask = 0
    #           @sum_rent_paid = 0
    #           @sum_service_charge_paid = 0
    #           @rents.each do |rent|
    #             @sum_rent_ask += rent.rent_ask
    #             @sum_service_charge_ask += rent.service_charge_ask
    #             @sum_rent_paid += rent.rent_paid
    #             @sum_service_charge_paid += rent.service_charge_paid
    #           end
    #           @solde = @sum_rent_ask + @sum_service_charge_ask - @sum_rent_paid - @sum_service_charge_paid
    #           @loyer_annuel = (@tenant.rent + @tenant.service_charge) *12
    #           @building_sum_rent_ask += @sum_rent_ask
    #           @building_sum_service_charge_ask += @sum_service_charge_ask
    #           @building_sum_rent_paid += @sum_rent_paid
    #           @building_sum_service_charge_paid += @sum_service_charge_paid
    #           @building_solde += @solde
    #           @building_loyer_annuel += @loyer_annuel
    #         end
    #       end
    # @company_building_sum_rent_ask += @building_sum_rent_ask
    # @company_building_sum_service_charge_ask += @building_sum_service_charge_ask
    # @company_building_sum_rent_paid += @building_sum_rent_paid
    # @company_building_sum_service_charge_paid += @building_sum_service_charge_paid
    # @company_building_solde += @building_solde
    # @company_building_loyer_annuel += @building_loyer_annuel
    #     end
    #   end
    # end
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
      # Update all building with correct company name
      @buildings = Building.where("company_id = ?", @company)
      @buildings.each do |t|
        t.company_name = @company.name
        t.save
      end
      # Update all apartments ith correct company name
      @apartments = Apartment.where("company_id = ?", @company)
      @apartments.each do |t|
        t.company_name = @company.name
        t.save
      end
      # Update all tenants ith correct company name
      @tenants = Tenant.where("company_id = ?", @company)
      @tenants.each do |t|
        t.company_name = @company.name
        t.save
      end
      # Update all expenses ith correct company name
      @expense = Expense.where("company_id = ?", @company)
      @expense.each do |t|
        t.company_name = @company.name
        t.save
      end
      redirect_to companies_path
    else
      render :edit
    end
  end

  def destroy
    authorize @company
    @company.name = @company.name+" deleted #{@company.id}"
    @company.statut = "deleted"
    @company.save
    # Flag as delete all building from this company
    @buildings = Building.where("company_id = ?", @company)
    @buildings.each do |t|
      t.statut = "deleted"
      t.save
    end
    # Flag as delete all apartment from this company
    @apartments = Apartment.where("company_id = ?", @company)
    @apartments.each do |t|
      t.statut = "deleted"
      t.save
    end
    # Flag as delete all tenants from this company
    @tenants = Tenant.where("company_id = ?", @company)
    @tenants.each do |t|
      t.statut = "deleted"
      t.save
      # Flag as delete all rents from this company
      t.rents.each do |r|
        r.statut = "deleted"
        r.save
      end
    end
    # Flag as delete all expense from this company
    @expense = Expense.where("company_id = ?", @company)
    @expense.each do |t|
      t.statut = "deleted"
      t.save
    end
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
