require 'yaml'

module CMA
  def self.config
    @config ||= load_config.with_indifferent_access
  end 
  
  private
    def self.load_config
      cma_config = YAML.load_file "#{Rails.root}/config/cma-archives.yml"
      cma_config[Rails.env] || {}
    end
end
