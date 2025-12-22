class MagicLinkMailer < ApplicationMailer
  def sign_in_instructions(magic_link)
    @magic_link = magic_link
    @code = magic_link.code

    mail(
      to: magic_link.identity.email_address,
      subject: "Il tuo codice di accesso: #{@code}"
    )
  end
end
