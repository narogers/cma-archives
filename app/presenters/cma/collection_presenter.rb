# Presentation assistance for collection pages 
module CMA
  class CollectionPresenter < Sufia::CollectionPresenter
    include Hydra::Presenter
    include ActionView::Helpers::NumberHelper

    def bytes
      return "#{number_to_human_size(model.bytes)} bytes"
    end

    def description
      return model.description.present? ?
        model.description :
        "No description available"
    end

    def thumbnail
      icon = ""
      if model.has_audio?
        icon = "fa-volume-up"
      elsif model.has_images?
        icon = "fa-photo"
      elsif model.has_video?
        icon = "fa-video-camera"
      elsif model.has_pdfs?
        icon = "fa-archive"
      else
        # NoOp
      end
    end

    def date_created
      return model.date_created.first 
    end

    def id
      return model.id
    end

    def summary
      return "#{model.members.count} members (#{number_to_human_size(model.bytes)})"  
    end

    def member_count
      return model.member_ids.count
    end

    # Retrieve a list of members from Solr for faster performance.
    #
    # TODO: Figure out how to do ranged based queries and refresh only part
    #       of the interface
    def member_presenters
      @member_presenters ||= build_presenters
    end

    # Path to any includes
    #
    # TODO: Figure out where to refactor this so that it makes more sense
    def partial_path
      return model.class.to_s.underscore
    end

    private
      def build_presenters
        members = ActiveFedora::SolrService.query("{!join from=hasCollectionMember_ssim to=id}id:(#{model.id})", {rows: model.member_ids.count})

        presenters = []
        members.each do |m|
          klass = "CMA::#{m.model}Presenter".constantize
          presenters << klass.new(m.reify)
        end

        return presenters
      end
  end
end
