class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "noreply@esercizi.paolotax.it")
  layout "mailer"
end
