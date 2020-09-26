# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'github_api'

Rails.application.load_tasks

namespace :authors do
  task :refresh do
    issues_api = Github::Client::Issues.new
    # puts 1.day.ago.iso8601
    issues = issues_api.list user: 'alvinlau', repo: 'bookstore', since: 1.day.ago.iso8601
    events = issues_api.events.list user: 'alvinlau', repo: 'bookstore', since: 1.day.ago.iso8601

    # issues.map {|i| pp i}
    puts 'closed issues'
    closed_github_issue_ids = events.filter{|e| e.event == 'closed'}.map{|e| e.issue.id}
    puts closed_github_issue_ids
    Author.where(github_issue_id: closed_github_issue_ids).destroy_all

    # Author.create(name: "Clark Kent")
    Setting.where(name: 'github_update').first.update(value: 0.days.ago.iso8601)
  end
end
