module CMA
  module Datastreams
    module ExternalFile
      def stream(range = nil)
        LocalFileBody.new(container.local_file)
      end

      def size
        File.size(container.local_file)
      end
  
      private 
        def retrieve_content
          File.binread(container.local_file)
        end
    end
  end
end
