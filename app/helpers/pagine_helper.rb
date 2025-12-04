module PagineHelper
  def default_badge_color
    if @pagina&.base_color.present?
      "#{@pagina.base_color}-500"
    else
      "blue-500"
    end
  end

  def imparare_tutti_badge(numero, colore: nil)
    colore ||= default_badge_color
    content_tag(:span, class: "inline-flex items-center mr-2") do
      concat(content_tag(:span, numero, class: "bg-#{colore} text-white rounded-full w-8 h-8 min-w-8 inline-flex items-center justify-center font-bold flex-shrink-0 z-10 relative"))
      concat(content_tag(:span, "IMPARARE TUTTI", class: "bg-yellow-300 text-#{colore} font-bold pl-5 pr-4 rounded-r-full -ml-3 whitespace-nowrap"))
    end
  end

  def numero_esercizio_badge(numero, colore: nil)
    colore ||= default_badge_color
    content_tag(:span, numero, class: "mr-2 w-8 h-8 min-w-8 bg-#{colore} text-white rounded-full inline-flex items-center justify-center font-bold")
  end
end
