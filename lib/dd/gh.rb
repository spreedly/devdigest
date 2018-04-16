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
      repos = get_repos(ENV['GITHUB_REPOS'], @org)
      collect(@org, repos)

      body = "## Github activity in the #{@org} org\n\n"
      if(@digest.length > 0)
        body += @digest
      else
        body += "*No activity reported for the monitored repos in this time period*"
      end
      body += "\n*The following repositories were included in this digest: #{repos.join(", ")}*"
    end

    private

    def add(row)
      @digest << "#{row}\n"
    end

    def collect(org, repos)
      repos.each do |repo|

        begin
          commits = @github.repos.commits.list(org, repo, since: @since.iso8601)

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
        rescue => e
          puts e.to_s
          e.backtrace.each { |line| puts line }
          add "!! Error getting commits for #{repo} (see logs for details)"
          add ""
        end
      end
    end

    def get_repos(repo_patterns, org)
      return @repos if @repos
      @repos = []
      all_repos = @github.repos.list(:org => org).collect{ |repo| repo.name }

      if repo_patterns
        @repos = repo_patterns.split(",").collect do |pattern|
          all_repos.select { |repo| repo.match?(pattern) }
        end
      else
        @repos = all_repos
      end
      @repos = @repos.flatten.compact.uniq.sort
    end

  end
end
