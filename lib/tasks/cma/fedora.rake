# Helper tasks for interacting with Fedora outside the repository
require 'optparse'

namespace :fedora do
  desc "Export batches, collections, and image metadata from repository"
  task :export, [:directory] => :environment do |t, args|
    if (args[:directory].nil?)
      puts "WARNING: No directory declared"
      next
    end

    ExportDataToJsonJob.new(args[:directory]).run
  end
end
