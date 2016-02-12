namespace :cma do
    namespace :collection do
        desc "Batch update metadata for members of collection(s)"
        task :update_members, [:csv] => :environment do |t, args|
          if args[:csv].present? and File.exists? args[:csv]
            print "Updating member metadata for collection(s)\n"
            Sufia.queue.push(UpdateCollectionMembersJob.new(args[:csv]))
          else
            print "WARNING: Provide a valid CSV file to continue\n"
          end
        end

        desc "Update collection level metadata"
        task :update_metadata, [:csv] => :environment do |t, args|
          if args[:csv].present? and File.exists? args[:csv]
            print "Updating collection level metadata\n"
            Sufia.queue.push(UpdateCollectionMetadataJob.new(args[:csv]))
          else
            print "WARNING: CSV file could not be found\n"
          end
        end

        desc "Reprocess EXIF metadata for all objects"
        task :extract_exif => :environment do
            query = "has_model_ssim:GenericFile"
            limits = {fl: "id, title_tesim", rows: GenericFile.count}
            solr_results = ActiveFedora::SolrService.query(query, limits)
        
            gf_ids = {}
            solr_results.map do |r| 
               gf_ids[r["id"]] = 
                  r["title_tesim"].nil? ? "<Undefined" : r["title_tesim"].first 
            end
        
            gf_ids.each do |id, title|
               puts "[#{id}] Processing #{title}\n"
               if not GenericFile.exists? id
                  puts "WARNING: Could not locate #{id} in Fedora"
                  next
               end
               extraction_job = ExtractExifMetadataJob.new(id)
               extraction_job.run
          end
       end

       desc "Normalize collection metadata"
       task :normalize => :environment do
           i = 1;
           Collection.find_each do |c|
             print "#{i} / #{Collection.count} - Normalizing #{c.title}\n"
             c.normalize_title
             c.save
             i += 1
           end
       end

       # Loads default collections into the repository. These should
       # be the umbrella collections that will be featured on the home
       # page
       #
       # The YAML format can be seen in config/default_collections.yml 
       desc "Install default collections"
       task :install_featured => :environment do
          # TODO: Make the CSV path configurable instead of a hard coded
          #       setting
          default_collections_source = "config/default_collections.yml"
          default_collections = YAML.load_file(default_collections_source)

          default_collections.each do |coll|
            # Not efficient at all but gets the job done
            # Given how many times it gets used could be refactored into the
            # collection model
            next if coll["name"].empty?

            query = "title_tesim:\"#{coll["name"]}\""
            result_count = ActiveFedora::SolrService.count(query)

            case result_count
            when 0
              print "Processing #{coll["name"]}\n"
              parent_collection = Collection.new(title: coll["name"],
                description: coll["description"],
                depositor: "admin",
                edit_users: [:admin],
                edit_groups: [:admin],
                read_groups: [coll["groups"]])

              if parent_collection.save
                FeaturedCollection.create(collection_id: parent_collection.id)
                print "Collection has been created as #{parent_collection.id}\n"
              else
                binding.pry
                print "ERROR: #{parent_collection.errors.to_s}\n"
              end
            else
              print "WARNING: #{coll["name"]} already exists\n"
            end
          end
        end
    end
end
