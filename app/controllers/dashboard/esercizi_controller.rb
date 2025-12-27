# frozen_string_literal: true

class Dashboard::EserciziController < ApplicationController
  require_teacher

  before_action :set_esercizio, only: [:show, :edit, :update, :destroy, :duplicate, :preview, :publish, :unpublish]

  def index
    @esercizi = current_scope.includes(:questions, :esercizio_attempts)

    @esercizi = @esercizi.by_category(params[:category]) if params[:category].present?
    @esercizi = @esercizi.by_difficulty(params[:difficulty]) if params[:difficulty].present?
    @esercizi = @esercizi.with_tag(params[:tag]) if params[:tag].present?

    @esercizi = case params[:status]
                when "published" then @esercizi.published
                when "draft" then @esercizi.drafts
                when "shared" then @esercizi.where(status: :shared)
                else @esercizi
                end

    @esercizi = @esercizi.order(created_at: :desc)
    @pagy, @esercizi = pagy(@esercizi, items: 12)
  end

  def show
    @attempts = @esercizio.esercizio_attempts.order(created_at: :desc).limit(10)
  end

  def new
    @esercizio = Esercizio.new
  end

  def create
    @esercizio = Esercizio.new(esercizio_params)
    @esercizio.creator = Current.user
    @esercizio.account = Current.account

    if @esercizio.save
      redirect_to edit_dashboard_esercizio_path(@esercizio), notice: "Esercizio creato. Aggiungi le domande."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @esercizio.update(esercizio_params)
      respond_to do |format|
        format.html { redirect_to dashboard_esercizio_path(@esercizio), notice: "Esercizio aggiornato." }
        format.turbo_stream
        format.json { render json: @esercizio }
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @esercizio.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @esercizio.destroy
    redirect_to dashboard_esercizi_path, notice: "Esercizio eliminato."
  end

  def duplicate
    new_esercizio = @esercizio.dup
    new_esercizio.title = "#{@esercizio.title} (copia)"
    new_esercizio.slug = nil
    new_esercizio.share_token = nil
    new_esercizio.status = :draft
    new_esercizio.published_at = nil
    new_esercizio.views_count = 0

    if new_esercizio.save
      # Duplica anche le questions
      @esercizio.questions.each do |question|
        new_questionable = question.questionable.dup
        new_questionable.save!

        new_esercizio.questions.create!(
          questionable: new_questionable,
          position: question.position,
          points: question.points,
          difficulty: question.difficulty,
          creator: Current.user,
          account: Current.account
        )
      end

      redirect_to edit_dashboard_esercizio_path(new_esercizio), notice: "Esercizio duplicato."
    else
      redirect_to dashboard_esercizi_path, alert: "Errore nella duplicazione."
    end
  end

  def preview
    render layout: "preview"
  end

  def publish
    @esercizio.publish!
    respond_to do |format|
      format.html { redirect_to dashboard_esercizio_path(@esercizio), notice: "Esercizio pubblicato." }
      format.turbo_stream
    end
  end

  def unpublish
    @esercizio.unpublish!
    respond_to do |format|
      format.html { redirect_to dashboard_esercizio_path(@esercizio), notice: "Esercizio ritirato." }
      format.turbo_stream
    end
  end

  private

  def set_esercizio
    @esercizio = current_scope.find(params[:id])
  end

  def current_scope
    if Current.account
      Esercizio.where(account: Current.account).or(Esercizio.where(creator: Current.user))
    else
      Esercizio.where(creator: Current.user)
    end
  end

  def esercizio_params
    params.require(:esercizio).permit(
      :title, :description, :category, :difficulty, :status,
      tags: []
    )
  end
end
