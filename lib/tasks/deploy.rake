
namespace_with_fontana :deploy, :"app:deploy" do

  set_url_and_branch = ->{
    ENV['URL'] ||= `git remote -v`.scan(/origin\s+(.+?)\s/).flatten.uniq.first
    ENV['BRANCH'] ||= `git status`.scan(/^.+\sbranch\s(.+)\s*$/).flatten.first
  }

  desc "deploy:setup deploy:update"
  fontana_task :reset, before: set_url_and_branch

  desc "drop DB, initialize, clear workspaces, clone, checkout branch. $URL required."
  fontana_task :setup, before: set_url_and_branch

  desc "fetch, checkout, build app_seed and migrate."
  fontana_task :update
end
