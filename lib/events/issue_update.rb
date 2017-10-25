module Events
  class IssueUpdate < Event
    WEEK = 7 * 24 * 60 * 60

    def process
      close_stale_issues
    end

    private

      def prefixes
        tag_matches[1].to_s.split(" ")
      end

      def tag_matches
        title.match(/^\[(.+)\]/) || []
      end

      def title
        issue.title
      end

      def issue
        payload.issue || payload.pull_request
      end

      def close_stale_issues
        stale_issues.each do |issue|
          github.close_issue(repo, issue.number)
          github.add_comment(repo, issue.number, "[BEEP BOOP] Hi there!\n\nThis issue/PR hasn't been updated in _a month_ so am closing it for now.\n\nFeel free to re-open in the future if/when it becomes relevant again! :heart:")
        end
      end

      def stale_issues
        github.search_issues("repo:#{repo} is:open updated:<#{stale_pr_cutoff_date}").items
      end

      def repo
        payload.repository.full_name
      end

      def stale_pr_cutoff_date
        (Time.now - 4 * WEEK).iso8601
      end

      def github
        Cp8.github_client
      end
  end
end
