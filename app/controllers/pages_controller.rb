class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:tutoriel]

  def home
    @tenant = Tenant.where("email = ?", current_user.email)[0]
  end
end
