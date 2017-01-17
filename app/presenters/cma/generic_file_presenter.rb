# Copied from Sufia::GenericFilePresenter
module CMA
  class GenericFilePresenter
    include ActionView::Helpers::NumberHelper
    include Hydra::Presenter

    self.model_class = ::GenericFile

    self.terms = [:date_created,
      :date_modified, :language, :abstract, :category, :accession_number, 
      :subject, :coverage, :creator, :photographer, :photographer_title, 
      :credit_line, :contributor, :rights]

    def bytes
      return "#{number_to_human_size(model.bytes)}"
    end

    def date_created
      return model.date_created.present? ? 
        model.date_created.sort : 
        ["-"]
    end

    def description
      return model.description.present? ?
        model.description :
        ""
    end

    def device
      return model.device.sort 
    end

    def id
      return model.id
    end

    def itemtype
      "http://schema.org/CreativeWork"
    end

    def title
      if model.title.is_a? Array
        model.title.first
      else
        model.title
      end
    end

    def member_presenters
      return []
    end
  end
end
