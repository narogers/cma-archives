class Collection < Sufia::Collection
  include Hydra::Collection
  include CMA::Collection::Featured
  include CMA::Collection::CollectionSize
  include CMA::Collection::CollectionType

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

  # Default Sufia makes collections always public which is not needed here
  # so we override the method to make the before_save a noop.
  def update_permissions
    # Noop
  end 
end
