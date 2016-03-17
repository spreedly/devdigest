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
      if(@digest.length > 0)
        <<-EOS
## Github activity in the #{@org} org

#{@digest}
        EOS
      else
        <<-EOS
## Github activity in the #{@org} org

*No activity reported for the monitored repos in this time period*
        EOS
      end
    end

    private

    def add(row)
      @digest << "#{row}\n"
    end

    def collect(org)

      repos = get_repos(ENV['GITHUB_REPOS'], org)
      repos.each do |repo_and_org|

        # repo can contain an override org
        repo, repo_org = repo_and_org.split("@").push(org)
        commits = @github.repos.commits.list(repo_org, repo, since: @since.iso8601)

        if commits.any?

          add "### Commits to #{repo}/master"
          add ""

          commits.each do |commit_data|
            commit = commit_data["commit"]
            if(commit && commit["message"])
              commit_msg = commit["message"].split("\n").first
              add "* [#{commit_msg}](#{commit_data["html_url"]}) by #{commit["committer"]["name"]}"
            end
          end
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
