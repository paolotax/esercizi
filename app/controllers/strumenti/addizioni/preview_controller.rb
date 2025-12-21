class Strumenti::Addizioni::PreviewController < ApplicationController
  def create
    @options = parse_options
    @addizioni = parse_addizioni_with_options(@operations, @options) if @operations.present?
  end
end
