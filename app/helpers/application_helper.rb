module ApplicationHelper
  def resource_type_facet_value value
    return "Subcollection" if value.eql? "Collection"
    # Otherwise return the original value
    return value
  end
end
