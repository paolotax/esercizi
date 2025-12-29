# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin!

    private

    def require_admin!
      unless Current.user&.admin?
        redirect_to root_path, alert: "Accesso riservato"
      end
    end
  end
end
