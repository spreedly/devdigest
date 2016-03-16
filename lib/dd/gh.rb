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
      add "## Github activity in #{org}"
      add ""

      repos = get_repos(ENV['GITHUB_REPOS'], org)

      activity = {}

      important_events = {
        "PullRequestEvent" => lambda { |event|
          action        = event.payload.action # opened/closed/reopened/synchronize
          pull_request  = event.payload.pull_request
          link          = "[pull request](#{pull_request.html_url})"
          [ pull_request.title, link ]
        },
        "PushEvent" => lambda { |event|
          commits  = event.payload.commits
          if commits.empty?
            ['empty','pushed']
          else
            [
              commits.first.message.split("\n").first,
              "[commit](#{commits.last.url.sub!("api.github.com/repos", "github.com").sub!("commits", "commit")})"
            ]
          end
        }
      }

      repos.each do |repo_and_org|
        # repo can contain an override org
        repo, repo_org = repo_and_org.split("@").push(org)

        puts "Crawling #{repo_org} / #{repo}"

        # collect activities
        res = @github.activity.events.repository(repo_org, repo)
        collected_all = false
        res.each_page do |page|
          page.each do |event|

            if Time.parse(event.created_at) < @since.utc
              puts "We're done: #{Time.parse(event.created_at)} (#{@since.utc})"
              collected_all = true
              break
            end

            next unless important_events.has_key?(event.type)

            activity[repo] ||= {}
            activity[repo][event.actor.login] ||= {}
            title, link = important_events[event.type].call(event)
            activity[repo][event.actor.login][title] ||= []
            activity[repo][event.actor.login][title] << link

          end
          break if collected_all
        end
      end

      activity.each do |repo, user_activity|
        add "### #{repo} activity"
        add ""
        user_activity.each do |user, activity|
          activity.each do |title, links|
            add "* #{links.join(', ')} #{title}"
          end
        end
        add ""
      end

      add ""
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
