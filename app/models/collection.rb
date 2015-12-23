class Collection < Sufia::Collection
  # Given a String representation of a directory attempts to convert it
  # a collection title using a standard series of rules. Input should
  # look something like
  # 
  # 2010-12 DB Parade the Circle
  #
  def self.extract_from_path(path)
    return path
  end
end
