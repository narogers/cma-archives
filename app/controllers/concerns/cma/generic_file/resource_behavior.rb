module CMA
  module GenericFile
     module ResourceBehavior
       def collections
         resource.collections
       end
       
       def resource
         @generic_file
       end
     end
  end
end
