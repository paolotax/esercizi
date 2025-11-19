# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "js-confetti", to: "https://esm.sh/js-confetti@latest"
pin_all_from "app/javascript/controllers", under: "controllers"
