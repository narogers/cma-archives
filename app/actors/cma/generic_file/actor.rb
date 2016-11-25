module CMA::GenericFile
  class Actor < Sufia::GenericFile::Actor
    def push_characterize_job
      Sufia.queue.push ProcessImportedFileJob.new(@generic_file.id)
    end
  end
end
