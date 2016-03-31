require 'pry'

namespace :resque do
  namespace :pool do
    desc "Start Resque pool"
    task :start do
      on roles(:workers) do
        within app_path do
          execute :bundle, :exec, "resque-pool", "--daemon", "--hot-swap",
            "--environment #{fetch(:rails_env)}", "--term-graceful"
        end
      end
    end

    desc "Restart Resque workers"
    task :restart do
      invoke "resque:pool:start"
    end

    desc "Stop Resque pool"
    task :stop do
      on roles(:workers) do
        execute :kill, "-QUIT", pid
      end
    end

    # Te same but don't give it time to wind down any long running jobs
    desc "Stop Resque pool immediately"
    task :kill do
      on roles(:workers) do
        execute :kill, "-INT", pid
      end
    end

    desc "Getting status of pool"
    task :status do
      on roles(:all) do
         pool_pid = pid
         unless pid.nil?
           info "Resque is running (PID #{pool_pid})"
         else
           info "Resque does not appear to be running"
         end
      end
    end

    def app_path
      File.join(fetch(:deploy_to), "current")
    end

    # Capture the oldest one to avoid including the SSH commands
    def pid
      pid = nil
      begin
        pid = capture :pgrep, "-o -f resque-pool"
      rescue SSHKit::Command::Failed
      end
  
      pid  
    end
  end
end
