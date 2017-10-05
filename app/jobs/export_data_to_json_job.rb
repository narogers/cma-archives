class ExportDataToJsonJob
  attr_accessor :root_directory, :csv_report

  def initialize(root_directory)
    self.root_directory = File.expand_path(root_directory)
  end

  def run 
    create_directories
    create_report

    Collection.find_each do |collection|
      export_collection(collection)
      collection.member_ids.each do |resource_id|
        export_resource(resource_id)
      end
    end
    close_report
  end

  protected
    def create_directories
      if (not Dir.exists? root_directory)
        FileUtils.mkdir_p(root_directory, mode: 0755)
      end

      puts "[EXPORT] Generating storage directories"
      collection_path = "#{root_directory}#{File::Separator}collections" 
      FileUtils.mkdir(collection_path, mode: 0755) unless Dir.exists?(collection_path)
    end

    def create_report
      self.csv_report = CSV.open("#{root_directory}/exports.csv", "w")
      self.csv_report << ["Identifier", "Title", "Collection ID", "Collection Title", "Collection Policy", "Exported"]
    end

    def close_report
      self.csv_report.close unless self.csv_report.closed?
    end

    def log_json_export(resource, exported = false)
      csv_row = [resource.id]
      csv_row << (resource.title.empty? ? "" : resource.title.first)
      csv_row << (resource.collection_ids.empty? ? "" : resource.collections.first.id)
      csv_row << (resource.collection_ids.empty? ? "" : resource.collections.first.title)
      csv_row << (resource.administrative_collection.nil? ? "" : resource.administrative_collection.title)
      csv_row << exported

      self.csv_report << csv_row
    end

    def export_collection(collection)
      if collection.administrative_collection.nil?
        puts "[EXPORT] WARNING: No valid policy found. Skipping collection"
        return
      end

      puts "[EXPORT] Exporting #{collection.title} (#{collection.id})"
      json = {
        id: collection.id,
        title: collection.title,
        description: collection.description,
        date_created: collection.date_created.first,
        policy: collection.administrative_collection.title,
        members: collection.member_ids
      }

      json_file = "#{root_directory}#{File::Separator}collections#{File::Separator}#{collection.id}.json"
      File.open(json_file, "w") { |f| f << json.to_json }
    end

    def export_resource(resource_id)
      file = GenericFile.find resource_id
      puts "[EXPORT] Exporting #{file.title.first} (#{file.id})"
      
      json_destination = "#{root_directory}#{File::Separator}collections#{File::Separator}#{file.collection_ids.first}"
      FileUtils.mkdir(json_destination) unless Dir.exists? json_destination
      
      begin
        json = {
          id: file.id,
          batch: file.batch_id,
          filename: file.filename,
          policy: file.administrative_collection.title,
          metadata: file.to_json
        }
        if (file.content.has_content?) 
          json[:datastreams][:master] = {
            original_name: file.content.original_name,
            checksum: file.content.checksum,
            mime_type: file.content.mime_type
          }
        end
        if (file.thumbnail.has_content?) 
          json[:datastreams][:thumbnail] = {
            original_name: file.thumbnail.original_name,
            checksum: file.thumbnail.checksum,
            mime_type: file.thumbnail.mime_type
        }
        end
        if (file.access.has_content?) 
          json[:datastreams][:access] = {
            original_name: file.access.original_name,
            checksum: file.access.checksum,
            mime_type: file.access.mime_type
          }
        end
        
        File.open("#{json_destination}#{File::Separator}#{file.id}.json", "w") { |f| f << json.to_json }
        log_json_export(file, true)

      rescue Ldp::HttpError => error
        puts "[EXPORT] ERROR: Could not export #{file.id}"
        puts "[EXPORT] #{error}"
        log_json_export(file, false)
      end

      
   end
end
