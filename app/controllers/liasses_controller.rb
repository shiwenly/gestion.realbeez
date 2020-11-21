class LiassesController < ApplicationController

  skip_before_action :authenticate_user!, only: []
  before_action :set_liasse, only: [:edit, :show, :update, :destroy]

  def index
    @building = Building.find(params[:building_id])
    @liasses = policy_scope(Liasse.where("statut = ? AND building_id = ?", "active", @building.id).order(year: :asc))
    @apartments = policy_scope(Apartment.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
    unless @apartments == []
      @building_sum_rent_ask = 0
      @building_sum_service_charge_ask = 0
      @building_sum_rent_paid = 0
      @building_sum_service_charge_paid = 0
      @building_solde = 0
      @building_loyer_annuel = 0
      @apartments.each do |apartment|
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
            @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.statut == "active" && a.tenant.apartment == apartment && a.tenant.apartment.building == @building }.sort_by { |b| b.period }
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
    end
  end

  def show
    authorize @liasse
    @building = @liasse.building
    # Appartments
    authorize @building
    @apartments = policy_scope(Apartment.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
    unless @apartments == []
      @building_sum_rent_ask = 0
      @building_sum_service_charge_ask = 0
      @building_sum_rent_paid = 0
      @building_sum_service_charge_paid = 0
      @building_solde = 0
      @building_loyer_annuel = 0
      @apartments.each do |apartment|
        unless apartment.tenants == []
          @apartment_sum_rent_ask = 0
          @apartment_sum_service_charge_ask = 0
          @apartment_sum_rent_paid = 0
          @apartment_sum_service_charge_paid = 0
          @apartment_solde = 0
          @loyer_annuel = (apartment.tenants.last.rent + apartment.tenants.last.service_charge) *12
          # Calculation
          apartment.tenants.each do |tenant|
            @rents_unorder = Rent.search_by_date(@liasse.year.strftime("%Y").to_i)
            @rents = @rents_unorder.select{|a| a.statut == "active" && a.tenant_id == tenant.id && a.tenant.statut == "active" && a.tenant.apartment == apartment && a.tenant.apartment.building == @building }.sort_by { |b| b.period }
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
    end
    # Expense
    # @expenses = policy_scope(Expense.where("statut = ? AND building_id = ?", "active", @building.id).order(created_at: :asc))
    @expenses_unorder = Expense.search_by_date_expense(@liasse.year.strftime("%Y").to_i)
    @expenses = @expenses_unorder.select{|a| a.statut == "active" && a.building_id == @building.id}.sort_by { |b| b.date }
    @sum_ttc = @expenses.map{|a| a.amount_ttc}.sum
    @sum_vat = @expenses.map{|a| a.amount_vat}.sum
    # Assurance
    @assurance = @expenses.select{|a| a.expense_type == "Assurance" && a.deductible == true }
    @sum_assurance = @assurance.map{|a| a.amount_ttc}.sum
    # Eau
    @eau = @expenses.select{|a| a.expense_type == "Eau" && a.deductible == true}
    @sum_eau = @eau.map{|a| a.amount_ttc}.sum
    # Eléctricité
    @electricite = @expenses.select{|a| a.expense_type == "Eléctricité" && a.deductible == true}
    @sum_electricite = @electricite.map{|a| a.amount_ttc}.sum
    # Frais bancaire
    @frais_bancaire = @expenses.select{|a| a.expense_type == "Frais bancaire" && a.deductible == true}
    @sum_frais_bancaire = @frais_bancaire.map{|a| a.amount_ttc}.sum
    # Honoraire
    @honoraire = @expenses.select{|a| a.expense_type == "Honoraire de gestion" && a.deductible == true}
    @sum_honoraire = @honoraire.map{|a| a.amount_ttc}.sum
    # Frais de nettoyage
    @frais_nettoyage = @expenses.select{|a| a.expense_type == "Frais de nettoyage" && a.deductible == true}
    @sum_frais_nettoyage = @frais_nettoyage.map{|a| a.amount_ttc}.sum
    # Maintenance chaudiere
    @maintenance_chaudiere = @expenses.select{|a| a.expense_type == "Maintenance chaudière" && a.deductible == true}
    @sum_maintenance_chaudiere = @maintenance_chaudiere.map{|a| a.amount_ttc}.sum
    # Remplacement chaudiere
    @remplacement_chaudiere = @expenses.select{|a| a.expense_type == "Remplacement chaudière" && a.deductible == true}
    @sum_remplacement_chaudiere = @remplacement_chaudiere.map{|a| a.amount_ttc}.sum
    # Réparation
    @reparation = @expenses.select{|a| a.expense_type == "Réparation, entretien et amélioration" && a.deductible == true}
    @sum_reparation = @reparation.map{|a| a.amount_ttc}.sum
    # Inreret
    @interet = @expenses.select{|a| a.expense_type == "Intérêt d'emprunt" && a.deductible == true}
    @sum_interet = @interet.map{|a| a.amount_ttc}.sum
    # Taxe
    @taxe = @expenses.select{|a| a.expense_type == "Taxe foncière" && a.deductible == true}
    @sum_taxe = @taxe.map{|a| a.amount_ttc}.sum
    # Notaire
    @notaire = @expenses.select{|a| a.expense_type == "Frais de notaire" && a.deductible == true}
    @sum_notaire = @notaire.map{|a| a.amount_ttc}.sum
    # Frais de dossier et caution
    @dossier = @expenses.select{|a| a.expense_type == "Frais de dossiers et caution" && a.deductible == true}
    @sum_dossier = @dossier.map{|a| a.amount_ttc}.sum
    # Charge non payé
    @non_paye = @expenses.select{|a| a.expense_type == "Charges non payées au départ du locataire" && a.deductible == true}
    @sum_non_paye = @non_paye.map{|a| a.amount_ttc}.sum
    # Frais admin
    @frais_admin = @sum_frais_bancaire + @sum_honoraire + @sum_dossier
    # Autre frais non deductible
    @autre_frais_non_deductible = 20 * @building.number_of_flat
    # Depense de réparataion
    @depense_de_reparation = @sum_frais_nettoyage + @sum_remplacement_chaudiere + @sum_reparation
    # Total deduction
    @total_deduction = @frais_admin + @autre_frais_non_deductible + @depense_de_reparation + @sum_assurance + @sum_taxe + @sum_non_paye
    # Total revenus
    @revenus = @building_sum_rent_paid - @total_deduction - @sum_interet
  end

  def new
    authorize @liasse = Liasse.new
    @building = Building.find(params[:building_id])
    # @apartment_name = ["Tous"]
    # @apartments_name = @building.apartments.each do |apartment|
    #   @apartment_name  << apartment.name.to_s
    # end
  end

  def create
    authorize @liasse = Liasse.new(liasse_params)
    @building = Building.find(params[:building_id])
    @liasse.building = @building
    @liasse.user_id = current_user.id
    @liasse.statut = "active"
    @liasse.year2 = @liasse.year.strftime("%Y").to_i
    if @liasse.save
      redirect_to building_liasses_path(@building)
    else
      render :new
    end
  end

  def edit
    authorize @liasse
    # @apartment_name = ["Tous"]
    # @apartments_name = @liasse.building.apartments.each do |apartment|
    #   @apartment_name  << apartment.name.to_s
    # end
  end

  def update
    authorize @liasse
    if @liasse.update(liasse_params)
      redirect_to building_liasses_path(@liasse.building)
    else
      render :edit
    end
  end

  def destroy
    authorize @liasse
    @liasse.statut = "deleted"
    @liasse.save
    redirect_to building_liasses_path(@liasse.building)
  end

  private

  def liasse_params
    params.require(:liasse).permit(
      :year
    )
  end

  def set_liasse
    @liasse = Liasse.find(params[:id])
  end

end
