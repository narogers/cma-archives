# -*- coding: utf-8 -*-
class GenericFilesController < ApplicationController
  include Sufia::Controller
  include Sufia::FilesControllerBehavior
  # Patches for local features
  include CMA::Breadcrumbs
  include CMA::GenericFile::ResourceBehavior
end
