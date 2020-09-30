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

    renamed_events = events.filter{|e| e.event == 'renamed' && e.created_at > last_update_time}
    unless renamed_events.empty?
      renamed_events.each do |e| 
        author = Author.where(github_issue_num: e.issue.number).first
        print "rename author #{author.name} to #{e.issue.title} ... "  
        author.update(name: e.issue.title)
        puts 'done'
      end
    end

    # filter out pull requests
    issues.select{|i| i.pull_request.nil?}.each do |issue|
      puts 'issue ' + issue.number.to_s
      # create author if there's none with matching github issue number
      authors_found = Author.where(github_issue_num: issue.number)
      if authors_found.empty?
        print "create author #{issue.title} - #{issue.number} ... "
        author = Author.create(name: issue.title, bio: issue.body, github_issue_num: issue.number)
        author.books.create(title: 'First Book From ' + issue.title, price: 9.99, author: author, publisher: author)
        puts 'done'
      end

      print "update bio for author #{issue.title} - #{issue.number} ... "
      authors_found.first.update(bio: issue.body)
      puts 'done'
    end

    closed_events = events.filter{|e| e.event == 'closed' && e.created_at > last_update_time}
    unless closed_events.empty?
      closed_github_issue_nums = closed_events.map{|e| e.issue.number}
      closed_events.each{|e| puts "delete author #{e.issue.title}"}
      authors = Author.where(github_issue_num: closed_github_issue_nums)
      authors.each{|author| author.books.destroy_all}
      authors.destroy_all
      puts 'done deleting authors and their books'
    end

    new_timestamp = 0.days.ago.iso8601
    Setting.where(name: 'github_update').first.update(value: new_timestamp)
    puts "completed refresh author from github issues at #{new_timestamp}"
  end
end
