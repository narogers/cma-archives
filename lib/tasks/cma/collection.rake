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
               ExtractExifMetadataJob.new(id).run
          end
       end

       desc "Normalize collection metadata"
       task :normalize => :environment do
           i = 1;
           Collection.find_each do |c|
             print "#{i} / #{Collection.count.freeze} - Normalizing #{c.title}\n"
             c.normalize_title
             c.save
             i += 1
           end
       end

       # Updates permissions for collections based on the settings for the
       # parent. To take advantage of this update the master collections (Editorial,
       # Object Photography, etc) and then run this in the background
       desc "Update collection permissions"
       task :update_permissions => :environment do
         Sufia.queue.push(ReindexCollectionPermissionsJob.new)
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
          source = "config/default_collections.yml"        
          InstallFeaturedCollectionsJob.new(source).run
        end
    end
end
