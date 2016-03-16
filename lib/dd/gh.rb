require 'time'

module Dd
  class Gh
    def initialize(token, org, since)
      @org = org
      @github = Github.new oauth_token: token, auto_pagination: true
      @digest = ""
      @since = since
    end

    def run
      collect(@org)
      @digest
    end

    private

    def add(row)
      @digest << "#{row}\n"
    end

    def collect(org)

      add "## Github activity in the #{org} org"
      add ""

      repos = get_repos(ENV['GITHUB_REPOS'], org)
      repos.each do |repo_and_org|

        # repo can contain an override org
        repo, repo_org = repo_and_org.split("@").push(org)

        add "### Commits to #{repo}/master"
        add ""

        commits = @github.repos.commits.list(repo_org, repo, since: @since.iso8601)
        if commits.any?
          commits.each do |commit_data|
            commit = commit_data["commit"]
            if(commit && commit["message"])
              commit_msg = commit["message"].split("\n").first
              add "* [#{commit_msg}](#{commit["url"]}) by #{commit["committer"]["name"]}"
            end
          end
        else
          add "*No activity for this period*"
          add ""
        end
      end

      rescue => e
        add e.to_s
        e.backtrace.each { |line| add(' ' + line) }
    end

    def get_repos(repos, org)
      if repos
        repos = repos.split(",")
      else
        repos = []
        @github.repos.list(:org => org) { |repo|
          repos << repo.name
        }
      end
      repos.sort
      repos
    end

  end
end
