module CMA
  class CharacterizationService
    def self.characterize content
      uri = "http://localhost:8888/fits/FitsService"
      # No point continuing if there is nothing to process
      return unless content.has_content?

      # Otherwise create a temporary version then run it against FITS
      Hydra::Derivatives::TempfileService.create(content) do |f|
        # Make the file world readable so the service can actually see.
        # Otherwise you get some weird errors from FITS
        f.chmod(0644)
        response = HTTParty.get(uri, query: {file: f.path})
        if 200 == response.code
          binding.pry
          return response.body
        else
          raise UnexpectedServerResponse("Received HTTP status code #{response.code} from #{uri}")
        end
      end
    end
  end

  class UnexpectedServerResponse < RuntimeError; end
end
