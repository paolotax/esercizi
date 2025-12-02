module PagineHelper
  def imparare_tutti_badge(numero)
    content_tag(:div, class: "flex items-center") do
      concat(content_tag(:div, numero, class: "bg-cyan-700 text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0 z-10 relative"))
      concat(content_tag(:span, "IMPARARE TUTTI", class: "bg-yellow-300 text-cyan-700 font-bold pl-5 pr-4 py-1 rounded-r-full -ml-3 whitespace-nowrap"))
    end
  end

  def numero_esercizio_badge(numero, colore: "blue-500")
    content_tag(:div, numero, class: "bg-#{colore} text-white rounded-full w-8 h-8 flex items-center justify-center font-bold flex-shrink-0")
  end
end
