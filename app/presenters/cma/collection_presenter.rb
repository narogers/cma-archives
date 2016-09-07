# Presentation assistance for collection pages 
module CMA
  class CollectionPresenter < Sufia::CollectionPresenter
    include Hydra::Presenter
    include ActionView::Helpers::NumberHelper

    def description
      return model.description.present? ?
        model.description :
        "#{model.members.count} members (#{number_to_human_size(model.bytes)})"
    end

    # Retrieve a list of members from Solr for faster performance.
    #
    # TODO: Figure out how to do ranged based queries and refresh only part
    #       of the interface
    def member_presenters
      @member_presenters ||= build_presenters(model.member_ids)
    end

    private
      def build_presenters(ids)
        presenters = []
        ids.each do |id|
          member = ActiveFedora::Base.load_instance_from_solr(id)
          klass = "CMA::#{member.class}Presenter".constantize
          presenters << klass.new(member)
        end

        presenters
      end
  end
end
