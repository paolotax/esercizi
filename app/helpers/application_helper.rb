module ApplicationHelper
  include Pagy::Frontend

  def page_title_tag
    account_name = if Current.account && Current.session&.identity&.users&.many?
      Current.account&.name
    end
    tag.title [ @page_title, account_name, "Esercizi" ].compact.join(" | ")
  end

  def icon_tag(name, **options)
    tag.span class: class_names("icon icon--#{name}", options.delete(:class)), "aria-hidden": true, **options
  end

  def back_link_to(label, url, action, **options)
    link_to url,
      class: "absolute top-0.5 left-2 sm:left-4 bg-white/50 dark:bg-gray-800/50 backdrop-blur-xl border border-gray-200/50 dark:border-gray-700/50 rounded-2xl py-2 pr-4 pl-2 text-sm font-semibold inline-flex items-center gap-2 cursor-pointer transition-all duration-150 hover:bg-white/70 dark:hover:bg-gray-700/70 text-gray-800 dark:text-white",
      data: { controller: "hotkey", action: action }, **options do
      icon_tag("arrow-left", class: "w-5 h-5") +
      tag.span(label, class: "sr-only sm:not-sr-only text-base font-bold") +
      tag.kbd("ESC", class: "hide-on-touch -mt-2")
    end
  end
end
