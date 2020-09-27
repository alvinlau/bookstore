require_relative 'config/application'
require 'github_api'

Rails.application.load_tasks

namespace :authors do
  task :refresh do
    last_update_time = Setting.where(name: 'github_update').first.value
    puts "get github issues and events since #{last_update_time}"
    issues_api = Github::Client::Issues.new
    issues = issues_api.list(user: 'alvinlau', repo: 'bookstore', state: 'open', since: last_update_time)
    events = issues_api.events.list(user: 'alvinlau', repo: 'bookstore', since: last_update_time)
    puts issues.size.to_s + ' issues'
    puts events.size.to_s + ' events'

    issues.each do |issue|
      puts 'issue ' + issue.number.to_s
      authors_found = Author.where(github_issue_num: issue.number)
      if authors_found.empty?
        puts "create author #{issue.title} - #{issue.number}"
        Author.create(name: issue.title, bio: issue.body, github_issue_num: issue.number)
      end
      
      comments = issues_api.comments.list(
        user: 'alvinlau', 
        repo: 'bookstore', 
        number: issue.number, 
        since: last_update_time
      )
      unless comments.empty?
        puts "update author #{issue.title} - #{issue.number}"
        last_comment = comments.to_a.last.body
        authors_found.first.update(bio: last_comment)
      end
    end

    closed_events = events.filter{|e| e.event == 'closed'}
    closed_github_issue_nums = closed_events.map{|e| e.issue.number}
    Author.where(github_issue_num: closed_github_issue_nums).destroy_all
    closed_events.each{|e| puts "delete author #{e.issue.title}"}

    new_timestamp = 0.days.ago.iso8601
    Setting.where(name: 'github_update').first.update(value: new_timestamp)
    puts "completed refresh author from github issues at #{new_timestamp}"
  end
end
