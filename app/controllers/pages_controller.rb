class PagesController < ApplicationController
  def home
    @tenant = Tenant.where("email = ?", current_user.email)[0]
  end
end
