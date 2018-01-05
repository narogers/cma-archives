module CMA
  class ResourceTerms
    def self.general_terms
      [:date_created,
       :date_modified,
       :language,
       :abstract,
       :category,
       :accession_number,
       :subject,
       :coverage,
       :creator,
       :photographer,
       :photographer_title,
       :credit_line,
       :contributor,
       :rights
      ]
    end

    def self.conservation_terms
      [:division,
       :lighting,
       :component,
       :sample_id,
       :conservation_state,
       :technique,
       :conservation_type
      ]
    end
  end
end
