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
    link_to url, class: "absolute top-1 left-2 sm:left-4 p-2 rounded-full bg-gray-100 dark:bg-gray-700 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors flex items-center gap-2 cursor-pointer", data: { controller: "hotkey", action: action }, **options do
      icon_tag("arrow-left", class: "w-5 h-5") +
      tag.span(label, class: "sr-only sm:not-sr-only text-sm font-medium") +
      tag.kbd("ESC", class: "hidden sm:inline text-xs px-1.5 py-0.5 rounded bg-gray-200 dark:bg-gray-600 text-gray-500 dark:text-gray-400")
    end
  end
end
