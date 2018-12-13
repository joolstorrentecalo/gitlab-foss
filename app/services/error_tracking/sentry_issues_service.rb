# frozen_string_literal: true

module ErrorTracking
  class SentryIssuesService
    def initialize(url, token)
      @url = URI(url + '/issues/')
      @token = token
    end

    def execute(limit: 20, issue_status: 'unresolved')
      issues = get_issues(limit, issue_status)
      map_to_errors(issues)
    end

    private

    def get_issues(limit, issue_status)
      sentry_query = {
        query: "is:#{issue_status}",
        limit: limit
      }
      # "query=is:unresolved&limit=#{limit}&sort=date&statsPeriod=24h&shortIdLookup=1"

      resp = Gitlab::HTTP.get(@url.to_s,
        query: sentry_query,
        headers: {
        'Authorization' => "Bearer #{@token}"
      })

      if resp.code == 200
        resp.as_json
      else
        # TODO: Handle non 200 status (error)
        []
      end
    end

    def map_to_errors(issues)
      issues.map do |issue|
        map_to_error(issue)
      end
    end

    def map_to_error(issue)
      project = issue.fetch('project')
      metadata = issue.fetch('metadata')

      ErrorTracking::Error.new(
        id: issue.fetch('id'),
        first_seen: issue.fetch('firstSeen'),
        last_seen: issue.fetch('lastSeen'),
        title: issue.fetch('title'),
        type: issue.fetch('type'),
        user_count: issue.fetch('userCount'),
        count: issue.fetch('count'),
        message: metadata.fetch('value', nil),
        culprit: issue.fetch('culprit'),
        external_url: issue.fetch('permalink'),
        short_id: issue.fetch('shortId'),
        status: issue.fetch('status'),
        project_id: project.fetch('id'),
        project_name: project.fetch('name'),
        project_slug: project.fetch('slug'),
      )
    end
  end
end
