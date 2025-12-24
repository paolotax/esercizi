CREATE TABLE IF NOT EXISTS "esercizio_templates" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "category" varchar, "created_at" datetime(6) NOT NULL, "default_config" text DEFAULT '{}', "description" text, "name" varchar NOT NULL, "updated_at" datetime(6) NOT NULL, "usage_count" integer DEFAULT 0);
CREATE INDEX "index_esercizio_templates_on_category" ON "esercizio_templates" ("category") /*application='Esercizi'*/;
CREATE INDEX "index_esercizio_templates_on_name" ON "esercizio_templates" ("name") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "search_records" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "searchable_type" varchar NOT NULL, "searchable_id" integer NOT NULL, "pagina_id" integer, "disciplina_id" integer, "volume_id" integer, "title" varchar, "content" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_55e8b7ab18"
FOREIGN KEY ("pagina_id")
  REFERENCES "pagine" ("id")
, CONSTRAINT "fk_rails_bd29a24ace"
FOREIGN KEY ("disciplina_id")
  REFERENCES "discipline" ("id")
, CONSTRAINT "fk_rails_ebb84424e8"
FOREIGN KEY ("volume_id")
  REFERENCES "volumi" ("id")
);
CREATE INDEX "index_search_records_on_searchable" ON "search_records" ("searchable_type", "searchable_id") /*application='Esercizi'*/;
CREATE INDEX "index_search_records_on_pagina_id" ON "search_records" ("pagina_id") /*application='Esercizi'*/;
CREATE INDEX "index_search_records_on_disciplina_id" ON "search_records" ("disciplina_id") /*application='Esercizi'*/;
CREATE INDEX "index_search_records_on_volume_id" ON "search_records" ("volume_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_search_records_on_searchable_type_and_searchable_id" ON "search_records" ("searchable_type", "searchable_id") /*application='Esercizi'*/;
CREATE VIRTUAL TABLE search_records_fts USING fts5(
        title,
        content,
        tokenize='porter'
      )
/* search_records_fts(title,content) */;
CREATE TABLE IF NOT EXISTS 'search_records_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'search_records_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'search_records_fts_content'(id INTEGER PRIMARY KEY, c0, c1);
CREATE TABLE IF NOT EXISTS 'search_records_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'search_records_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS "identities" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email_address" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_identities_on_email_address" ON "identities" ("email_address") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "accounts" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "external_account_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_accounts_on_external_account_id" ON "accounts" ("external_account_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "account_id" integer NOT NULL, "identity_id" integer, "name" varchar NOT NULL, "role" varchar DEFAULT 'student' NOT NULL, "active" boolean DEFAULT TRUE NOT NULL, "verified_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_61ac11da2b"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_2f296ee649"
FOREIGN KEY ("identity_id")
  REFERENCES "identities" ("id")
);
CREATE INDEX "index_users_on_account_id" ON "users" ("account_id") /*application='Esercizi'*/;
CREATE INDEX "index_users_on_identity_id" ON "users" ("identity_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_users_on_account_id_and_identity_id" ON "users" ("account_id", "identity_id") /*application='Esercizi'*/;
CREATE INDEX "index_users_on_role" ON "users" ("role") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "sessions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "identity_id" integer NOT NULL, "ip_address" varchar, "user_agent" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_03f2f61b83"
FOREIGN KEY ("identity_id")
  REFERENCES "identities" ("id")
);
CREATE INDEX "index_sessions_on_identity_id" ON "sessions" ("identity_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "magic_links" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "identity_id" integer NOT NULL, "code" varchar NOT NULL, "expires_at" datetime(6) NOT NULL, "purpose" varchar DEFAULT 'sign_in', "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_1a96f2e287"
FOREIGN KEY ("identity_id")
  REFERENCES "identities" ("id")
);
CREATE INDEX "index_magic_links_on_identity_id" ON "magic_links" ("identity_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_magic_links_on_code" ON "magic_links" ("code") /*application='Esercizi'*/;
CREATE INDEX "index_magic_links_on_expires_at" ON "magic_links" ("expires_at") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "account_join_codes" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "account_id" integer NOT NULL, "code" varchar NOT NULL, "role" varchar DEFAULT 'student' NOT NULL, "usage_count" integer DEFAULT 0 NOT NULL, "usage_limit" integer DEFAULT 100 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c899033922"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_account_join_codes_on_account_id" ON "account_join_codes" ("account_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_account_join_codes_on_code" ON "account_join_codes" ("code") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "classi" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "account_id" integer NOT NULL, "teacher_id" integer NOT NULL, "name" varchar NOT NULL, "anno_scolastico" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_5f20b1c47e"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_e113c705a9"
FOREIGN KEY ("teacher_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_classi_on_account_id" ON "classi" ("account_id") /*application='Esercizi'*/;
CREATE INDEX "index_classi_on_teacher_id" ON "classi" ("teacher_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_classi_on_account_id_and_name_and_anno_scolastico" ON "classi" ("account_id", "name", "anno_scolastico") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "classe_memberships" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "classe_id" integer NOT NULL, "user_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_65ab5117f0"
FOREIGN KEY ("classe_id")
  REFERENCES "classi" ("id")
, CONSTRAINT "fk_rails_9bf93833a7"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_classe_memberships_on_classe_id" ON "classe_memberships" ("classe_id") /*application='Esercizi'*/;
CREATE INDEX "index_classe_memberships_on_user_id" ON "classe_memberships" ("user_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_classe_memberships_on_classe_id_and_user_id" ON "classe_memberships" ("classe_id", "user_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "corsi" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "codice" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "descrizione" text, "nome" varchar NOT NULL, "updated_at" datetime(6) NOT NULL, "account_id" integer, CONSTRAINT "fk_rails_1a1eb485f3"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE UNIQUE INDEX "index_corsi_on_codice" ON "corsi" ("codice") /*application='Esercizi'*/;
CREATE INDEX "index_corsi_on_account_id" ON "corsi" ("account_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "volumi" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "classe" integer, "corso_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "nome" varchar NOT NULL, "posizione" integer DEFAULT 0, "updated_at" datetime(6) NOT NULL, "account_id" integer, CONSTRAINT "fk_rails_17e2200900"
FOREIGN KEY ("corso_id")
  REFERENCES "corsi" ("id")
, CONSTRAINT "fk_rails_2e84871173"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_volumi_on_corso_id" ON "volumi" ("corso_id") /*application='Esercizi'*/;
CREATE INDEX "index_volumi_on_account_id" ON "volumi" ("account_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "discipline" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "codice" varchar NOT NULL, "colore" varchar, "created_at" datetime(6) NOT NULL, "nome" varchar NOT NULL, "updated_at" datetime(6) NOT NULL, "volume_id" integer NOT NULL, "account_id" integer, CONSTRAINT "fk_rails_d9b6a78c4e"
FOREIGN KEY ("volume_id")
  REFERENCES "volumi" ("id")
, CONSTRAINT "fk_rails_3da0a99c98"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_discipline_on_volume_id" ON "discipline" ("volume_id") /*application='Esercizi'*/;
CREATE INDEX "index_discipline_on_account_id" ON "discipline" ("account_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "pagine" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "base_color" varchar, "created_at" datetime(6) NOT NULL, "disciplina_id" integer NOT NULL, "numero" integer NOT NULL, "posizione" integer DEFAULT 0, "slug" varchar NOT NULL, "sottotitolo" varchar, "titolo" varchar, "updated_at" datetime(6) NOT NULL, "view_template" varchar, "account_id" integer, CONSTRAINT "fk_rails_b785608fe0"
FOREIGN KEY ("disciplina_id")
  REFERENCES "discipline" ("id")
, CONSTRAINT "fk_rails_b829e8ea4f"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
);
CREATE INDEX "index_pagine_on_disciplina_id" ON "pagine" ("disciplina_id") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_pagine_on_slug" ON "pagine" ("slug") /*application='Esercizi'*/;
CREATE INDEX "index_pagine_on_account_id" ON "pagine" ("account_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "esercizio_attempts" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "completed_at" datetime(6), "created_at" datetime(6) NOT NULL, "esercizio_id" integer NOT NULL, "results" text DEFAULT '{}', "score" float, "started_at" datetime(6), "student_identifier" varchar, "time_spent" integer, "updated_at" datetime(6) NOT NULL, "account_id" integer, "user_id" integer, CONSTRAINT "fk_rails_66fb9e9546"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_a6fb1428d3"
FOREIGN KEY ("esercizio_id")
  REFERENCES "esercizi" ("id")
, CONSTRAINT "fk_rails_e37d311032"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "idx_on_esercizio_id_student_identifier_efe29ead75" ON "esercizio_attempts" ("esercizio_id", "student_identifier") /*application='Esercizi'*/;
CREATE INDEX "index_esercizio_attempts_on_esercizio_id" ON "esercizio_attempts" ("esercizio_id") /*application='Esercizi'*/;
CREATE INDEX "index_esercizio_attempts_on_student_identifier" ON "esercizio_attempts" ("student_identifier") /*application='Esercizi'*/;
CREATE INDEX "index_esercizio_attempts_on_account_id" ON "esercizio_attempts" ("account_id") /*application='Esercizi'*/;
CREATE INDEX "index_esercizio_attempts_on_user_id" ON "esercizio_attempts" ("user_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "esercizi" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "category" varchar, "content" text DEFAULT '{}', "created_at" datetime(6) NOT NULL, "description" text, "difficulty" varchar, "published_at" datetime(6), "share_token" varchar, "slug" varchar NOT NULL, "tags" text DEFAULT '[]', "title" varchar NOT NULL, "updated_at" datetime(6) NOT NULL, "views_count" integer DEFAULT 0, "account_id" integer, "creator_id" integer, CONSTRAINT "fk_rails_caa2d9fc3f"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_462a2e5db2"
FOREIGN KEY ("creator_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_esercizi_on_category" ON "esercizi" ("category") /*application='Esercizi'*/;
CREATE INDEX "index_esercizi_on_published_at" ON "esercizi" ("published_at") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_esercizi_on_share_token" ON "esercizi" ("share_token") /*application='Esercizi'*/;
CREATE UNIQUE INDEX "index_esercizi_on_slug" ON "esercizi" ("slug") /*application='Esercizi'*/;
CREATE INDEX "index_esercizi_on_account_id" ON "esercizi" ("account_id") /*application='Esercizi'*/;
CREATE INDEX "index_esercizi_on_creator_id" ON "esercizi" ("creator_id") /*application='Esercizi'*/;
CREATE INDEX "index_corsi_on_account_id_and_created_at" ON "corsi" ("account_id", "created_at") /*application='Esercizi'*/;
CREATE INDEX "index_esercizi_on_account_id_and_created_at" ON "esercizi" ("account_id", "created_at") /*application='Esercizi'*/;
CREATE INDEX "index_esercizio_attempts_on_account_id_and_user_id" ON "esercizio_attempts" ("account_id", "user_id") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "questions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "esercizio_id" integer NOT NULL, "account_id" integer, "creator_id" integer, "questionable_type" varchar NOT NULL, "questionable_id" integer NOT NULL, "position" integer DEFAULT 0, "difficulty" integer, "points" integer, "time_limit" integer, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_a4b5fc738e"
FOREIGN KEY ("esercizio_id")
  REFERENCES "esercizi" ("id")
, CONSTRAINT "fk_rails_9da5b1c028"
FOREIGN KEY ("account_id")
  REFERENCES "accounts" ("id")
, CONSTRAINT "fk_rails_21f8d26270"
FOREIGN KEY ("creator_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_questions_on_esercizio_id" ON "questions" ("esercizio_id") /*application='Esercizi'*/;
CREATE INDEX "index_questions_on_account_id" ON "questions" ("account_id") /*application='Esercizi'*/;
CREATE INDEX "index_questions_on_creator_id" ON "questions" ("creator_id") /*application='Esercizi'*/;
CREATE INDEX "index_questions_on_questionable_type_and_questionable_id" ON "questions" ("questionable_type", "questionable_id") /*application='Esercizi'*/;
CREATE INDEX "index_questions_on_esercizio_id_and_position" ON "questions" ("esercizio_id", "position") /*application='Esercizi'*/;
CREATE TABLE IF NOT EXISTS "addizioni" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "data" json DEFAULT '{}' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "sottrazioni" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "data" json DEFAULT '{}' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
INSERT INTO "schema_migrations" (version) VALUES
('20251224103740'),
('20251224103643'),
('20251224103613'),
('20251222075055'),
('20251222075054'),
('20251222075053'),
('20251222075052'),
('20251222075051'),
('20251222075050'),
('20251222075049'),
('20251222075048'),
('20251222075047'),
('20251218112709'),
('20251123112725'),
('20251123103941'),
('20251123103913'),
('20251123103836'),
('20251115112225'),
('20251103095137'),
('20251103095136'),
('20251103095135'),
('20251103095134');

