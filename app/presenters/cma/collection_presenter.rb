# Presentation assistance for collection pages 
module CMA
  class CollectionPresenter < Sufia::CollectionPresenter
    include Hydra::Presenter
    include ActionView::Helpers::NumberHelper

    def initialize(model, member_ids = nil)
      super(model)
      @member_ids = member_ids || model.member_ids      
    end

    def bytes
      return "#{number_to_human_size(model.bytes)}"
    end

    def description
      return model.description.present? ?
        model.description :
        "No description available"
    end

    def date_created
      return model.date_created.first 
    end

    def id
      return model.id
    end

    def summary
      return "#{number_to_human_size(model.bytes)}"  
    end

    def member_count
      return model.member_ids.count
    end

    def member_presenters
      @member_presenters ||= build_presenters
    end

    def partial_path
      return model.class.to_s.underscore
    end

    private
      def build_presenters
        presenters = []
        @member_ids.each do |m_id|
          member = ActiveFedora::Base.load_instance_from_solr(m_id)
          klass = "CMA::#{member.class}Presenter".constantize
          presenters << klass.new(member)
        end

        return presenters
      end
  end
end
