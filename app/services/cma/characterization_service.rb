module CMA
  class CharacterizationService
    def self.characterize content
      # No point continuing if there is nothing to process
      return unless content.has_content?

      # Otherwise create a temporary version then run it against FITS
      Hydra::Derivatives::TempfileService.create(content) do |f|
        # Make the file world readable so the service can actually see.
        # Otherwise you get some weird errors from FITS
        f.chmod(0644)

        begin
          response = HTTParty.get(CMA.config["fits"]["uri"], 
            query: {file: f.path}, 
            timeout: CMA.config["fits"]["timeout"])
        rescue Net::ReadTimeout => timeout_error
          Rails.logger.warn "[CHARACTERIZE] Could not connect to #{CMA.config["fits"]["uri"]}?file=#{f.path} after waiting #{CMA.config["fits"]["timeout"]} seconds"
            raise timeout_error
        end

        if 200 == response.code
          # Kludge because the information that comes back from FITS Servlet is not
          # actually indicated to be UTF-8. Need to open an issue with the upstream
          # repository after which this code can be simplified
          Rails.logger.info "[CHARACTERIZE] Characterization complete for #{CMA.config["fits"]["uri"]}?file=#{f.path}"
          return response.body.force_encoding("iso-8859-1").encode("utf-8")
        else
          raise UnexpectedServerResponse.new("Received HTTP status code #{response.code} from #{CMA.config["fits"]["uri"]}")
        end
      end
    end
  end

  class UnexpectedServerResponse < RuntimeError; end
end
