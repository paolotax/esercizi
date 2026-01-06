# frozen_string_literal: true

module NavMenuHelper
  def jump_field_tag
    text_field_tag :search, nil,
      type: "search",
      role: "combobox",
      placeholder: "Cerca pagine, volumi, strumenti...",
      class: "nav__input w-full py-2 px-3 border border-gray-200 dark:border-gray-600 rounded-lg text-base bg-white dark:bg-gray-700 dark:text-white outline-none transition-colors duration-150 focus:border-blue-500 placeholder:text-gray-400",
      autofocus: true,
      autocomplete: "off",
      data: {
        filter_target: "input",
        nav_section_expander_target: "input",
        navigable_list_target: "input",
        action: "input->filter#filter input->nav-section-expander#showWhileFiltering"
      }
  end

  def nav_hotkey_link(title, path, key, icon_name)
    link_to path, class: "nav__hotkey-btn popup__item content-center aspect-[5/3] bg-gray-100 dark:bg-gray-700 rounded-lg basis-[calc((100%-16px)/3)] flex-col text-sm leading-none justify-center overflow-hidden relative text-center no-underline flex items-center gap-1 py-3 px-4 border-none cursor-pointer transition-colors duration-150 hover:bg-gray-200 dark:hover:bg-gray-600",
      data: {
        filter_target: "item",
        navigable_list_target: "item",
        controller: "hotkey",
        action: "keydown.#{key}@document->hotkey#click"
      } do
      safe_join([
        nav_icon(icon_name),
        tag.span(title),
        tag.kbd(key, class: "hide-on-touch absolute top-2 right-2 text-[0.65em] opacity-50 bg-transparent")
      ])
    end
  end

  def collapsible_nav_section(title, nested: false, &block)
    css_class = nested ? "nav__section popup__section nav__section--nested border-t border-gray-200 dark:border-gray-700 text-sm" : "nav__section popup__section border-t border-gray-200 dark:border-gray-700 text-sm"

    tag.details class: css_class,
      data: {
        action: "toggle->nav-section-expander#toggle",
        nav_section_expander_target: "section",
        nav_section_expander_key_value: title.parameterize
      },
      open: true do
      safe_join([
        tag.summary(class: "popup__section-title bg-white dark:bg-gray-800 text-xs font-semibold sticky top-0 py-2 px-2 uppercase z-10 text-gray-500 dark:text-gray-400 flex items-center gap-1 cursor-pointer list-none") do
          safe_join([
            nav_icon("caret-down"),
            title
          ])
        end,
        tag.ul(class: "popup__list flex flex-col w-full list-none m-0 p-0 gap-px ml-3") { capture(&block) }
      ])
    end
  end

  def nav_menu_link(path, label, icon_name, method: :get)
    tag.li class: "popup__item flex items-center bg-transparent rounded w-full hover:bg-gray-100 dark:hover:bg-gray-700 aria-selected:bg-blue-100 dark:aria-selected:bg-blue-900/50",
      data: { filter_target: "item", navigable_list_target: "item" } do
      if method == :delete
        button_to path, method: :delete, class: "popup__btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer" do
          safe_join([
            nav_icon(icon_name),
            tag.span(label, class: "overflow-ellipsis")
          ])
        end
      else
        link_to path, class: "popup__btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer" do
          safe_join([
            nav_icon(icon_name),
            tag.span(label, class: "overflow-ellipsis")
          ])
        end
      end
    end
  end

  def nav_menu_volume_item(volume)
    tag.li class: "popup__item flex items-center bg-transparent rounded w-full hover:bg-gray-100 dark:hover:bg-gray-700 aria-selected:bg-blue-100 dark:aria-selected:bg-blue-900/50",
      data: { filter_target: "item", navigable_list_target: "item" } do
      link_to volume_path(volume), class: "popup__btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer" do
        safe_join([
          nav_icon("book"),
          tag.span(volume.nome, class: "overflow-ellipsis")
        ])
      end
    end
  end

  def nav_menu_disciplina_item(disciplina)
    tag.li class: "popup__item flex items-center bg-transparent rounded w-full hover:bg-gray-100 dark:hover:bg-gray-700 aria-selected:bg-blue-100 dark:aria-selected:bg-blue-900/50",
      data: { filter_target: "item", navigable_list_target: "item" } do
      link_to disciplina_path(disciplina), class: "popup__btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer" do
        safe_join([
          nav_icon("folder"),
          tag.span(disciplina.nome, class: "overflow-ellipsis")
        ])
      end
    end
  end

  def nav_menu_pagina_item(pagina)
    tag.li class: "popup__item flex items-center bg-transparent rounded w-full hover:bg-gray-100 dark:hover:bg-gray-700 aria-selected:bg-blue-100 dark:aria-selected:bg-blue-900/50",
      data: { filter_target: "item", navigable_list_target: "item" } do
      link_to pagina_path(pagina.slug), class: "popup__btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer" do
        safe_join([
          nav_icon("page"),
          tag.span("p#{pagina.numero} - #{pagina.titolo.presence || 'Senza titolo'}", class: "overflow-ellipsis")
        ])
      end
    end
  end

  def nav_icon(name, size: :default)
    size_class = case size
    when :small then "text-xs"
    when :large then "text-xl"
    else "text-base"
    end

    icon_tag(name, class: "popup__icon #{size_class} w-6 flex items-center justify-center shrink-0 ml-1")
  end
end

# ============================================
# Fizzy
# ============================================

def filter_place_menu_item(path, label, icon, new_window: false, current: false, turbo: true)
  link_to_params = {}
  link_to_params.merge!({ target: "_blank" }) if new_window
  link_to_params.merge!({ data: { turbo: false } }) unless turbo

  tag.li class: "popup__item flex items-center bg-transparent rounded w-full hover:bg-gray-100 dark:hover:bg-gray-700 aria-selected:bg-blue-100 dark:aria-selected:bg-blue-900/50", id: "filter-place-#{label.parameterize}", data: { filter_target: "item", navigable_list_target: "item" }, aria: { checked: current } do
    concat icon_tag(icon, class: "popup__icon w-6 flex items-center justify-center shrink-0 ml-1")
    concat(link_to(path, link_to_params.merge(class: "popup__btn btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer"), data: { turbo: turbo }) do
      concat tag.span(label, class: "overflow-ellipsis")
      # concat icon_tag("check", class: "checked flex-item-justify-end", "aria-hidden": true)
    end)
  end
end

def my_menu_user_item(user)
  my_menu_item("person", user) do
    link_to(tag.span(user.name, class: "overflow-ellipsis"), user, class: "popup__btn btn rounded border-none bg-transparent flex-1 font-medium justify-start w-full min-w-0 py-2 px-1 text-left no-underline flex items-center gap-2 cursor-pointer")
  end
end

def my_menu_item(item, record)
  tag.li(class: "popup__item flex items-center bg-transparent rounded w-full hover:bg-gray-100 dark:hover:bg-gray-700 aria-selected:bg-blue-100 dark:aria-selected:bg-blue-900/50", data: { filter_target: "item", navigable_list_target: "item", id: "filter-#{item}-#{record.id}" }) do
    icon_tag(item, class: "popup__icon w-6 flex items-center justify-center shrink-0 ml-1") + yield
  end
end
