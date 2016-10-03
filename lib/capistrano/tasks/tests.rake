namespace :deploy do
  desc "Run test suites before deployment"
  task :test_suite do
    run_locally do
      execute :rake, 'test'
    end
  end
end
