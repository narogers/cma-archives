class Collection < Sufia::Collection
  # Emulate the relationship for members to apply to collections
  #
  # TODO : See if there is a similar relationship that exists for defining collections
  #        only
  has_and_belongs_to_many :subcollections, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasPart, 
    class_name: "ActiveFedora::Base"

  before_save do
    normalize_title
  end

  # Helper method to fix the casing of titles but retain certain acronyms
  #
  # Be sure that if you want overrides for acronym they are set in
  # config/initializers/inflections.rb
  def normalize_title
    # Shift everything to lower case first so that improperly cased acronyms
    # don't split into two words and then apply the titlecase
    self.title = self.title.downcase.titlecase
  end
end
