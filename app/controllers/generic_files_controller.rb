# -*- coding: utf-8 -*-
class GenericFilesController < ApplicationController
  include Blacklight::SearchContext
  include Sufia::Controller
  include Sufia::FilesControllerBehavior
  # Patches for local features
  include CMA::Breadcrumbs

  def self.presenter_class
    CMA::GenericFilePresenter
  end

  def show
    super
    @current_search_session = current_search_session
  end
end
