# frozen_string_literal: true

module NavMenuHelper
  def jump_field_tag
    text_field_tag :search, nil,
      type: "search",
      role: "combobox",
      placeholder: "Cerca pagine, volumi, strumenti...",
      class: "nav__input",
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
    link_to path, class: "nav__hotkey-btn popup__item",
      data: {
        filter_target: "item",
        navigable_list_target: "item",
        controller: "hotkey",
        action: "keydown.#{key}@document->hotkey#click"
      } do
      safe_join([
        nav_icon(icon_name),
        tag.span(title),
        tag.kbd(key, class: "hide-on-touch")
      ])
    end
  end

  def collapsible_nav_section(title, nested: false, &block)
    css_class = nested ? "nav__section popup__section nav__section--nested" : "nav__section popup__section"

    tag.details class: css_class,
      data: {
        action: "toggle->nav-section-expander#toggle",
        nav_section_expander_target: "section",
        nav_section_expander_key_value: title.parameterize
      },
      open: true do
      safe_join([
        tag.summary(class: "popup__section-title") do
          safe_join([
            nav_icon("caret-down"),
            title
          ])
        end,
        tag.ul(class: "popup__list") { capture(&block) }
      ])
    end
  end

  def nav_menu_link(path, label, icon_name, method: :get)
    tag.li class: "popup__item",
      data: { filter_target: "item", navigable_list_target: "item" } do
      if method == :delete
        button_to path, method: :delete, class: "popup__btn" do
          safe_join([
            nav_icon(icon_name),
            tag.span(label, class: "overflow-ellipsis")
          ])
        end
      else
        link_to path, class: "popup__btn" do
          safe_join([
            nav_icon(icon_name),
            tag.span(label, class: "overflow-ellipsis")
          ])
        end
      end
    end
  end

  def nav_menu_volume_item(volume)
    tag.li class: "popup__item",
      data: { filter_target: "item", navigable_list_target: "item" } do
      link_to volume_path(volume), class: "popup__btn" do
        safe_join([
          nav_icon("book"),
          tag.span(volume.nome, class: "overflow-ellipsis")
        ])
      end
    end
  end

  def nav_menu_disciplina_item(disciplina)
    tag.li class: "popup__item",
      data: { filter_target: "item", navigable_list_target: "item" } do
      link_to disciplina_path(disciplina), class: "popup__btn" do
        safe_join([
          nav_icon("folder"),
          tag.span(disciplina.nome, class: "overflow-ellipsis")
        ])
      end
    end
  end

  def nav_menu_pagina_item(pagina)
    tag.li class: "popup__item",
      data: { filter_target: "item", navigable_list_target: "item" } do
      link_to pagina_path(pagina.slug), class: "popup__btn" do
        safe_join([
          nav_icon("page"),
          tag.span("p#{pagina.numero} - #{pagina.titolo.presence || 'Senza titolo'}", class: "overflow-ellipsis")
        ])
      end
    end
  end

  def nav_icon(name)
    icons = {
      "caret-down" => '<svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>',
      "home" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"></path></svg>',
      "tools" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>',
      "dashboard" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"></path></svg>',
      "book" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"></path></svg>',
      "folder" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path></svg>',
      "page" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>',
      "calculator" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"></path></svg>',
      "plus" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>',
      "minus" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path></svg>',
      "x" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>',
      "divide" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v8m-4-4h8"></path><circle cx="12" cy="6" r="1" fill="currentColor"/><circle cx="12" cy="18" r="1" fill="currentColor"/></svg>',
      "music" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3"></path></svg>',
      "settings" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>',
      "logout" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path></svg>',
      "user" => '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path></svg>'
    }

    tag.span(icons[name]&.html_safe || "", class: "popup__icon")
  end
end

# ============================================
# Fizzy
# ============================================

def filter_place_menu_item(path, label, icon, new_window: false, current: false, turbo: true)
  link_to_params = {}
  link_to_params.merge!({ target: "_blank" }) if new_window
  link_to_params.merge!({ data: { turbo: false } }) unless turbo

  tag.li class: "popup__item", id: "filter-place-#{label.parameterize}", data: { filter_target: "item", navigable_list_target: "item" }, aria: { checked: current } do
    concat icon_tag(icon, class: "popup__icon")
    concat(link_to(path, link_to_params.merge(class: "popup__btn btn"), data: { turbo: turbo }) do
      concat tag.span(label, class: "overflow-ellipsis")
      concat icon_tag("check", class: "checked flex-item-justify-end", "aria-hidden": true)
    end)
  end
end

def my_menu_user_item(user)
  my_menu_item("person", user) do
    link_to(tag.span(user.name, class: "overflow-ellipsis"), user, class: "popup__btn btn")
  end
end

def my_menu_item(item, record)
  tag.li(class: "popup__item", data: { filter_target: "item", navigable_list_target: "item", id: "filter-#{item}-#{record.id}" }) do
    icon_tag(item, class: "popup__icon") + yield
  end
end
