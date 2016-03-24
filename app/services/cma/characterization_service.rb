module CMA
  class CharacterizationService
    def self.characterize content
      uri = "http://localhost:8888/fits/FitsService"
      # No point continuing if there is nothing to process
      return unless content.has_content?

      # Otherwise create a temporary version then run it against FITS
      metadata = nil
      Hydra::Derivatives::TempfileService.create(content) do |f|
        response = HTTParty.get(uri, query: {file: f.path})
        if 200 == response.code
          return response.body
        else
          raise UnexpectedServerResponse("Received HTTP status code #{response.code} from #{uri}")
        end
      end
    end
  end

  class UnexpectedServerResponse < RuntimeError; end
end
