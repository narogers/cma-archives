module CMA
  module Collection
     module ResourceBehavior
       def collections
         resource.collections
       end

       def resource
         @collection
       end
     end
  end
end
