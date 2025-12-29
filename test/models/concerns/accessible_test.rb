# frozen_string_literal: true

require "test_helper"

class AccessibleTest < ActiveSupport::TestCase
  setup do
    @corso = corsi(:corso_uno)
    @volume = volumi(:volume_uno)
    @disciplina = discipline(:matematica)
    @pagina = pagine(:pagina_uno)
    @mario = users(:mario_teacher)
    @luigi = users(:luigi_student)
    @account = accounts(:scuola_test)
  end

  # ============================================
  # shared_with? tests
  # ============================================

  test "shared_with? returns false when no shares exist" do
    # Remove all shares for this test
    Share.destroy_all

    assert_not @corso.shared_with?(@mario)
    assert_not @volume.shared_with?(@mario)
  end

  test "shared_with? returns true when user has direct share" do
    Share.create!(
      shareable: @corso,
      recipient: @mario,
      permission: :view
    )

    assert @corso.shared_with?(@mario)
  end

  test "shared_with? returns true when user account has share" do
    Share.create!(
      shareable: @volume,
      recipient: @account,
      permission: :view
    )

    assert @volume.shared_with?(@mario)
  end

  test "shared_with? returns false for expired shares" do
    # Clear all shares first to ensure clean state
    Share.destroy_all

    Share.create!(
      shareable: @corso,
      recipient: @mario,
      permission: :view,
      expires_at: 1.day.ago
    )

    assert_not @corso.shared_with?(@mario)
  end

  # ============================================
  # Corso accessible_by? tests
  # ============================================

  test "corso accessible_by? returns false for nil user" do
    assert_not @corso.accessible_by?(nil)
  end

  test "corso accessible_by? returns true for admin user" do
    admin = users(:admin_user)
    assert admin.admin?
    assert @corso.accessible_by?(admin)
  end

  test "corso accessible_by? returns true when shared with user" do
    Share.destroy_all
    Share.create!(shareable: @corso, recipient: @mario, permission: :view)

    assert @corso.accessible_by?(@mario)
  end

  test "corso accessible_by? returns false when not shared" do
    Share.destroy_all
    assert_not @corso.accessible_by?(@luigi)
  end

  # ============================================
  # Volume accessible_by? tests
  # ============================================

  test "volume accessible_by? returns true when shared directly" do
    Share.destroy_all
    Share.create!(shareable: @volume, recipient: @mario, permission: :view)

    assert @volume.accessible_by?(@mario)
  end

  test "volume accessible_by? returns true when corso is shared" do
    Share.destroy_all
    Share.create!(shareable: @corso, recipient: @mario, permission: :view)

    assert @volume.accessible_by?(@mario)
  end

  test "volume accessible_by? returns false when nothing shared" do
    Share.destroy_all
    assert_not @volume.accessible_by?(@luigi)
  end

  # ============================================
  # Disciplina accessible_by? tests
  # ============================================

  test "disciplina accessible_by? returns true when shared directly" do
    Share.destroy_all
    Share.create!(shareable: @disciplina, recipient: @mario, permission: :view)

    assert @disciplina.accessible_by?(@mario)
  end

  test "disciplina accessible_by? returns true when volume is shared" do
    Share.destroy_all
    Share.create!(shareable: @volume, recipient: @mario, permission: :view)

    assert @disciplina.accessible_by?(@mario)
  end

  test "disciplina accessible_by? returns true when corso is shared" do
    Share.destroy_all
    Share.create!(shareable: @corso, recipient: @mario, permission: :view)

    assert @disciplina.accessible_by?(@mario)
  end

  # ============================================
  # Pagina accessible_by? tests
  # ============================================

  test "pagina accessible_by? returns true when shared directly" do
    Share.destroy_all
    Share.create!(shareable: @pagina, recipient: @mario, permission: :view)

    assert @pagina.accessible_by?(@mario)
  end

  test "pagina accessible_by? returns true when disciplina is shared" do
    Share.destroy_all
    Share.create!(shareable: @disciplina, recipient: @mario, permission: :view)

    assert @pagina.accessible_by?(@mario)
  end

  test "pagina accessible_by? returns true when volume is shared" do
    Share.destroy_all
    Share.create!(shareable: @volume, recipient: @mario, permission: :view)

    assert @pagina.accessible_by?(@mario)
  end

  test "pagina accessible_by? returns true when corso is shared" do
    Share.destroy_all
    Share.create!(shareable: @corso, recipient: @mario, permission: :view)

    assert @pagina.accessible_by?(@mario)
  end

  test "pagina accessible_by? returns false when nothing shared" do
    Share.destroy_all
    assert_not @pagina.accessible_by?(@luigi)
  end

  # ============================================
  # accessible_by scope tests
  # ============================================

  test "Corso.accessible_by returns all for admin" do
    admin = users(:admin_user)
    assert_equal Corso.count, Corso.accessible_by(admin).count
  end

  test "Corso.accessible_by returns only shared corsi for regular user" do
    Share.destroy_all
    Share.create!(shareable: @corso, recipient: @mario, permission: :view)

    assert_equal 1, Corso.accessible_by(@mario).count
    assert_includes Corso.accessible_by(@mario), @corso
  end

  test "Pagina.accessible_by returns pagine when volume is shared" do
    Share.destroy_all
    Share.create!(shareable: @volume, recipient: @mario, permission: :view)

    accessible_pagine = Pagina.accessible_by(@mario)
    assert_includes accessible_pagine, @pagina
  end

  test "Pagina.accessible_by returns empty for user with no shares" do
    Share.destroy_all
    assert_empty Pagina.accessible_by(@luigi)
  end
end
