class ModifyAuthorsGithubIssueIdToNumber < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :github_issue_num, :integer
    remove_column :authors, :github_issue_id
  end
end
