class CatalogController < ApplicationController
  include Hydra::Catalog
  include Sufia::Catalog

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, only: :show
  # This applies appropriate access controls to all solr queries
  CatalogController.search_params_logic += [:add_access_controls_to_solr_params, :add_advanced_parse_q_to_solr]

  skip_before_filter :default_html_head

  def self.uploaded_field
    solr_name('date_uploaded', :stored_sortable, type: :date)
  end

  def self.modified_field
    solr_name('system_modified', :stored_sortable, type: :date)
  end

  def self.global_fields_with_scores
    global_fields ||= {
      Solrizer.solr_name("title", :stored_searchable) => 10,
      Solrizer.solr_name("accession_number", :stored_searchable) => 5,
      Solrizer.solr_name("id", :stored_searchable) => 5,
      Solrizer.solr_name("label", :stored_searchable) => 3,
      Solrizer.solr_name("description", :stored_searchable) => 1.5,
      Solrizer.solr_name("subject", :stored_searchable) => 1.5,
      Solrizer.solr_name("contributor", :stored_searchable) => 1,
      Solrizer.solr_name("photographer", :stored_searchable) => 1,
      #Solrizer.solr_name("technician", :stored_searchable) => 1
    }

    global_fields
  end

  configure_blacklight do |config|          
    config.per_page = [25, 50, 100, 250]

    config.view.gallery.partials = [:gallery_header, :gallery_details]
    config.view.gallery.icon_class = 'glyphicon-th-large'

    config.add_results_collection_tool :sort_widget
    config.add_results_collection_tool :view_type_group

    #config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    #config.show.partials.insert(1, :openseadragon)

    #Show gallery view
    #config.view.gallery.partials = [:index_header, :index]
    #config.view.slideshow.partials = [:index]

    # Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      sort: "primary_title_ssi DESC",
      qt: "search",
      rows: 50
    }

    # solr field configuration for document/show views
    config.index.title_field = solr_name("title", :stored_searchable)
    config.index.display_type_field = solr_name("has_model", :symbol)
    config.index.thumbnail_method = :preview_thumbnail_tag

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    config.add_facet_field solr_name("contributor_facet", :facetable), label: "Contributor", limit: 5
    config.add_facet_field solr_name("date_created", :dateable), label: "Date Created", range: true
    config.add_facet_field solr_name("file_format", :facetable), label: "File Format", limit: 5
    config.add_facet_field solr_name("subject", :facetable), label: "Subject", limit: 5
    config.add_facet_field solr_name("resource_type", :facetable), label: "Resource type", limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title", :stored_searchable), label: "Title", itemprop: 'name'
    config.add_index_field solr_name("description", :stored_searchable), label: "Description", itemprop: 'description'
    config.add_index_field solr_name("subject", :stored_searchable), label: "Subject", itemprop: 'about'
    config.add_index_field solr_name("creator", :stored_searchable), label: "Creator", itemprop: 'creator'
    config.add_index_field solr_name("contributor", :stored_searchable), label: "Contributor", itemprop: 'contributor'
    config.add_index_field solr_name("publisher", :stored_searchable), label: "Publisher", itemprop: 'publisher'
    config.add_index_field solr_name("language", :stored_searchable), label: "Language", itemprop: 'inLanguage'
    config.add_index_field solr_name("date_uploaded", :stored_searchable), label: "Date Uploaded", itemprop: 'datePublished'
    config.add_index_field solr_name("date_modified", :stored_searchable), label: "Date Modified", itemprop: 'dateModified'
    config.add_index_field solr_name("date_created", :stored_searchable), label: "Date Created", itemprop: 'dateCreated'
    config.add_index_field solr_name("rights", :stored_searchable), label: "Rights"
    config.add_index_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_index_field solr_name("format", :stored_searchable), label: "File Format"
    config.add_index_field solr_name("identifier", :stored_searchable), label: "Identifier"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name("title", :stored_searchable), label: "Title"
    config.add_show_field solr_name("description", :stored_searchable), label: "Description"
    #config.add_show_field solr_name("tag", :stored_searchable), label: "Keyword"
    config.add_show_field solr_name("subject", :stored_searchable), label: "Subject"
    config.add_show_field solr_name("creator", :stored_searchable), label: "Creator"
    config.add_show_field solr_name("contributor", :stored_searchable), label: "Contributor"
    config.add_show_field solr_name("photographer", :stored_searchable), label: "Photographer"
    config.add_show_field solr_name("publisher", :stored_searchable), label: "Publisher"
    config.add_show_field solr_name("language", :stored_searchable), label: "Language"
    config.add_show_field solr_name("date_uploaded", :stored_searchable), label: "Date Uploaded"
    config.add_show_field solr_name("date_modified", :stored_searchable), label: "Date Modified"
    config.add_show_field solr_name("date_created", :stored_searchable), label: "Date Created"
    config.add_show_field solr_name("rights", :stored_searchable), label: "Rights"
    config.add_show_field solr_name("resource_type", :stored_searchable), label: "Resource Type"
    config.add_show_field solr_name("format", :stored_searchable), label: "File Format"
    config.add_show_field solr_name("identifier", :stored_searchable), label: "Identifier"
    config.add_show_field solr_name("accession_number", :stored_searchable), label: "Accession Number"
 
    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.
    #
    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.
    config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false) do |field|
        all_fields = global_fields_with_scores.map { |f, score| "#{f}^#{score}" }.join(" ")
        title_name = solr_name("title", :stored_searchable)
        field.solr_parameters = {
          qf: "#{all_fields}",
          pf: "#{title_name}^10"
        }
      end

    config.add_search_field("accession_number") do |field|
       solr_name = solr_name("accession_number", :stored_searchable)
       field.solr_local_parameters = {
         qf: solr_name,
         pf: solr_name
       }
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.
    config.add_search_field('contributors') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      #field.solr_parameters = { :"spellcheck.dictionary" => "contributor" }

      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      solr_names = [
        solr_name("contributor", :stored_searchable),
        solr_name("photographer", :stored_searchable),
        solr_name("technician", :stored_searchable)
      ].join(" ")
      field.solr_local_parameters = {
        qf: solr_names,
        pf: solr_names
      }
    end

    config.add_search_field('description') do |field|
      field.label = "Description"
      solr_name = solr_name("description", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end
    
    config.add_search_field('identifier') do |field|
      field.include_in_advanced_search = false
      solr_name = solr_name("id", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "subject"
      }
      solr_name = solr_name("subject", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    config.add_search_field('title') do |field|
      field.solr_parameters = {
        :"spellcheck.dictionary" => "title"
      }
      solr_name = solr_name("title", :stored_searchable)
      field.solr_local_parameters = {
        qf: solr_name,
        pf: solr_name
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    # label is key, solr field is value
    config.add_sort_field "date_created_ssi ASC", label: "Date Created \u25BC"
    config.add_sort_field "date_created_ssi DESC", label: "Date Created \u25B2"
    config.add_sort_field "primary_title_ssi ASC", label: "Title \u25BC", 
      default: true
    config.add_sort_field "primary_title_ssi DESC", label: "Title \u25B2"
    config.add_sort_field "score DESC, #{uploaded_field} DESC \u25B2", label: "Relevance"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Use :post to work around URL requests to Solr becoming
    # exceedingly long
    config.http_method = :post
  end
 
end
