# Helper tasks for interacting with Fedora outside the repository
namespace :fedora do
  desc "Export batches, collections, and image metadata from repository"
  task :export, [:export_base] => :environment do
    ExportDataToJsonJob.new(export_base).run
  end
end