module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :ensure_can_access_account, if: -> { Current.account.present? && authenticated? }
  end

  class_methods do
    def allow_unauthorized_access(**options)
      skip_before_action :ensure_can_access_account, **options
    end

    def require_teacher(**options)
      before_action :ensure_teacher, **options
    end

    def require_owner(**options)
      before_action :ensure_owner, **options
    end
  end

  private
    def ensure_can_access_account
      redirect_to new_session_path(script_name: nil) if Current.user.blank? || !Current.user.active?
    end

    def ensure_teacher
      head :forbidden unless Current.user&.at_least_teacher?
    end

    def ensure_owner
      head :forbidden unless Current.user&.owner?
    end
end
