# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Esercizi** is an Italian educational platform for interactive exercises (math, grammar, etc.) organized in a textbook-like structure. Multi-tenant SaaS with account-scoped data.

- Rails 8.1, Ruby 3.2.2, SQLite, Tailwind CSS 4, Stimulus, Turbo
- Deployed via Kamal to esercizi.paolotax.it

## Commands

```bash
# Development
bin/rails server                    # Start server
bin/rails tailwindcss:build         # Build Tailwind CSS
bin/rails tailwindcss:watch         # Watch Tailwind changes

# Testing
bin/rails test                      # Run all tests
bin/rails test test/models/         # Run model tests only
bin/rails test test/models/user_test.rb:15  # Single test by line

# Code quality
bin/rubocop                         # Ruby linting
bin/brakeman                        # Security scanning

# Deployment
bin/kamal deploy                    # Deploy to production
bin/kamal console                   # Rails console on server
bin/kamal shell                     # SSH into container
```

## Architecture

### Content Hierarchy
```
Corso → Volume → Disciplina → Pagina
```
- **Corso**: Course (e.g., "Classe 3")
- **Volume**: Book within a course
- **Disciplina**: Subject (matematica, grammatica)
- **Pagina**: Individual page with exercises, uses `slug` for routing (e.g., `nvi4_mat_p012`)

### Multi-Tenant Auth System
- `Current` thread-local stores: `account`, `identity`, `user`, `session`
- `Identity` = email-based login (passwordless via MagicLink)
- `User` = account-scoped profile with role (student/teacher/owner)
- One identity can have users in multiple accounts
- Authentication: `Authentication` concern with `ViaMagicLink`
- Authorization: `Authorization` concern, `User::Admin` for admin checks

### Access Control (Shareable Resources)
- `Shareable` concern: generates share tokens for public URLs
- `Accessible` concern: manages share permissions (user or account recipients)
- 4-level inheritance: Corso → Volume → Disciplina → Pagina
- Admin emails configured in credentials

### Exercise Page Templates
Pages live in `app/views/exercises/{slug}.html.erb` (e.g., `nvi4_mat_p012.html.erb`).

Template naming convention:
- `bus3_mat_*` = Classe 3 matematica
- `nvi4_mat_*` = Classe 4 matematica
- `nvl5_gram_*` = Classe 5 grammatica

### Stimulus Controllers
50+ exercise controllers in `app/javascript/controllers/`:
- `page_viewer_controller.js` - Main page navigation
- `fill_blanks_controller.js` - Fill-in exercises
- `exercise_checker_controller.js` - Answer validation
- `quaderno_*_controller.js` - Math operations (add/sub/mul/div)
- `abaco_controller.js` - Abacus tool
- `word_*_controller.js` - Word exercises (sorter, selector, highlighter)

### Math Operation Models
`app/models/` has specialized models with `Renderer` classes:
- `Addizione`, `Sottrazione`, `Moltiplicazione`, `Divisione`
- Each has `Renderer` for HTML generation and `Calculation` for logic

## Tailwind CSS 4

**DO NOT use `tailwind.config.js`** - Tailwind 4 uses CSS-based configuration.

Custom theme in `app/assets/tailwind/application.css`:
```css
@import "tailwindcss";

@theme {
  --animate-shake: shake 0.5s ease-in-out;
  --color-custom-pink: #C657A0;
}

@keyframes shake { /* ... */ }
```

## Key Patterns

### Controller Concerns
- `Authentication`: Session management, magic links
- `Authorization`: Role-based access (`require_teacher`, `require_owner`)

### View Helpers
- `ExercisesHelper`: Exercise rendering utilities
- `OperazioniHelper`: Math operation display

### Dashboard (Teacher Area)
`/dashboard/esercizi` - CRUD for custom exercises with:
- Questions management
- Sharing system
- Publishing workflow

## Important Notes

- **Git commits**: Always ask for confirmation before committing unless user says "committatutto"
- **Page creation**: Use skill `crea-nuova-pagina` for new exercise pages
- **Dark mode**: Use skill `revisione-dark-mode` for dark mode updates
