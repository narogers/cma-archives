module CMAHelper
  def render_partial_for(partial, member=nil)
    root_path = member.class.to_s.underscore

    # This should look something like collection/collection/row
    # or collection/generic_file/row
    partial = "collections/#{root_path}#{File::Separator}#{partial}"

    render partial, {member: member}
  end

  # Given a collection object will choose either the description field,
  # if present, or the path for the folder. This is a bit of a bandaid
  # patch until the metadata can be updated
  def description_for_collection collection
     description = 'No description available'
     if collection.description.present?
       description = collection.description
     else
       first_member = collection.members.first
       unless first_member.nil?
         description = File.dirname(first_member.import_url)
         description = Addressable::URI.parse(description).path
       end
     end

     return description
  end

  # Alternative method for constructing breadcrumbs that lets you expand out
  # subcollections
  def breadcrumbs_for member
    breadcrumb_trail = breadcrumb_links_for member
    content_tag :ul, class: 'breadcrumb' do 
      breadcrumb_trail.map do |entry|
        content_tag :li do
          entry[:label]
        end
      end.join.html_safe
    end
  end

  # TODO: Defend against circular collection loops
  def breadcrumb_links_for member
    breadcrumbs = []
    
    unless member.collections.empty?
      breadcrumbs = breadcrumb_links_for member.collections.first 
    end
    breadcrumbs += [{label: member.title}] 

    return breadcrumbs
  end
end
