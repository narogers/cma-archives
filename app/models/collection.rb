class Collection < Sufia::Collection
  include CMA::Collection::Featured
  include CMA::Collection::Relations
  include CMA::Collection::CollectionSize
  include CMA::Collection::MimeType

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

  # A bodge to move forward with the interface redesign. Needs to be fixed to
  # be much more DRY
  def resource_path
    "/collections/#{id}"
  end
end
