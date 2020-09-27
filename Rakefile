# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'github_api'

Rails.application.load_tasks

namespace :authors do
  task :refresh do
    last_update_time = Setting.where(name: 'github_update').first.value
    issues_api = Github::Client::Issues.new
    issues = issues_api.list user: 'alvinlau', repo: 'bookstore', since: 3.day.ago.iso8601
    # events = issues_api.events.list user: 'alvinlau', repo: 'bookstore', since: 1.day.ago.iso8601
    # issues = issues_api.list user: 'alvinlau', repo: 'bookstore', since: last_update_time
    events = issues_api.events.list user: 'alvinlau', repo: 'bookstore', since: last_update_time

    issues.each do |issue|
      authors_found = Author.where(github_issue_id: issue.id)
      if authors_found.empty?
        puts "create author #{issue.title} - #{issue.id}"
        Author.create(name: issue.title, github_issue_id: issue.id)
      else
        puts "update author #{issue.title} - #{issue.id}"
        # comments = 
        # authors_found.first.update()
      end
    end


    puts 'closed issues'
    closed_github_issue_ids = events.filter{|e| e.event == 'closed'}
                                    .map{|e| e.issue.id}
    puts closed_github_issue_ids
    Author.where(github_issue_id: closed_github_issue_ids).destroy_all

    Setting.where(name: 'github_update').first.update(value: 0.days.ago.iso8601)
  end
end
