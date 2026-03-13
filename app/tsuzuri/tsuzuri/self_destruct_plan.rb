module Tsuzuri
  class SelfDestructPlan
    def published_posts_count
      Post.published.count
    end

    def active_followers_count
      Follower.active.count
    end

    def known_servers_count
      KnownServer.reachable.count
    end

    def estimated_activities
      # One Delete per published post + one Actor Delete
      published_posts_count + 1
    end
  end
end
