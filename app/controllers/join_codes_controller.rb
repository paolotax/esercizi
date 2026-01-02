class JoinCodesController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { head :too_many_requests }

  before_action :set_join_code
  before_action :ensure_join_code_is_valid

  layout "public"

  def new
  end

  def create
    identity = find_or_create_identity

    @join_code.redeem_if do |account, role|
      identity.join(account, role: role)
    end

    user = User.active.find_by!(account: @join_code.account, identity: identity)

    if identity == Current.identity && user.verified?
      redirect_to root_url(script_name: @join_code.account.slug)
    elsif identity == Current.identity
      redirect_to new_users_verification_url(script_name: @join_code.account.slug)
    else
      terminate_session if Current.identity
      redirect_to_session_magic_link(
        identity.send_magic_link,
        return_to: new_users_verification_url(script_name: @join_code.account.slug)
      )
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  private
    def find_or_create_identity
      Identity.find_or_create_by!(email_address: params[:email_address])
    end

    def set_join_code
      @join_code = Account::JoinCode.find_by(code: params[:code], account: Current.account)
    end

    def ensure_join_code_is_valid
      if @join_code.nil?
        head :not_found
      elsif !@join_code.active?
        render :inactive, status: :gone
      end
    end
end
