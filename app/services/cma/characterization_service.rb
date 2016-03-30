module CMA
  class CharacterizationService
    def self.characterize content
      # TODO: Make these configurable
      uri = "http://127.0.0.1:8888/fits/FitsService"
      max_retries = 3

      # No point continuing if there is nothing to process
      return unless content.has_content?

      # Otherwise create a temporary version then run it against FITS
      Hydra::Derivatives::TempfileService.create(content) do |f|
        # Make the file world readable so the service can actually see.
        # Otherwise you get some weird errors from FITS
        f.chmod(0644)

        times_retried = 0
        begin
          response = HTTParty.get(uri, query: {file: f.path}, timeout: 180)
        rescue Net::Timeout
          if times_retried < max_retries
            times_retried += 1
            Rails.logger.warn "[CHARACTERIZE] Unable to connect to uri"
            retry
          else
            Rails.logger.warn "[CHARACTERIZE] Could not connect to #{uri} after {#max_retries} attempts"
            raise UnexpectedServerResponse("Connection repeatedly timed out") 
          end 
        end
        if 200 == response.code
          #binding.pry
          # Kludge because the information that comes back from FITS Servlet is not
          # actually indicated to be UTF-8. Need to open an issue with the upstream
          # repository after which this code can be simplified
          return response.body.force_encoding("iso-8859-1").encode("utf-8")
        else
          raise UnexpectedServerResponse("Received HTTP status code #{response.code} from #{uri}")
        end
      end
    end
  end

  class UnexpectedServerResponse < RuntimeError; end
end
