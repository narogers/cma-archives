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

  # Override default behaviour of making everything public to inherit the
  # permissions of the parent (if it is present). There's a danger here in
  # infinite loops that exists elsewhere in the code so tread with caution
  def update_permissions
    if self.collections.present?
      parent = collections.first
      self.read_groups = parent.read_groups
      self.edit_groups = parent.edit_groups
    end
  end 
end
