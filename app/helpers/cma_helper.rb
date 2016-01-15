module CMAHelper
  def render_partial_for(partial, member=nil)
    root_path = member.class.to_s.underscore

    # This should look something like collection/collection/row
    # or collection/generic_file/row
    partial = "collections/#{root_path}#{File::Separator}#{partial}"

    render partial, {member: member}
  end
end
