# Copied from Sufia::GenericFilePresenter
module CMA
  class GenericFilePresenter
    include Hydra::Presenter
    self.model_class = ::GenericFile

    self.terms = [:date_created,
      :date_modified, :language, :abstract, :category, :subject, :coverage, 
      :creator, :photographer, :photographer_title, :credit_line, :contributor,
      :rights]

    def bytes
      return "#{number_to_human_size(model.bytes)} bytes"
    end

    def date_created
      return model.date_created.present? ? 
        [Date.parse(model.date_created.first).strftime("%B %e, %Y")] :
        ["-"]
    end

    def description
      return model.description.present? ?
        model.description :
        ""
    end

    def id
      return model.id
    end

    def itemtype
      "http://schema.org/CreativeWork"
    end

    def title
      return model.title.first
    end

    def member_presenters
      return []
    end
  end
end
