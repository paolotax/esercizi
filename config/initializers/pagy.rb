# Pagy Configuration
require "pagy/extras/overflow"

# Set default items per page
Pagy::DEFAULT[:items] = 12

# Handle overflow by showing last page
Pagy::DEFAULT[:overflow] = :last_page

# Customize Pagy i18n
# Pagy::I18n.load(locale: 'it')
