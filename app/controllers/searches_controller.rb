class SearchesController < ApplicationController
  allow_any_account_scope

  def show
    @query = params[:q].to_s.strip
    @results = Search::Record.search(@query).limit(50).to_a if @query.present?
  end
end
