# Copied from Sufia::GenericFilePresenter
module CMA
  class GenericFilePresenter
    include Hydra::Presenter
    self.model_class = ::GenericFile

    self.terms = [:title, :description, :date_created,
      :date_modified, :abstract, :category, :subject, :coverage, :creator, 
      :photographer, :photographer_title, :credit_line, :rights]

    def itemtype
      "http://schema.org/CreativeWork"
    end
  end
end
