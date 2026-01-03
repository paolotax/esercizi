module QrCodesHelper
  def qr_code_image(url)
    qr_code_link = QrCodeLink.new(url)
    image_tag qr_code_path(qr_code_link.signed), class: "mx-auto max-w-48", alt: "QR Code"
  end
end
