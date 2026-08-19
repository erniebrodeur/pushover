module Pushover
  # Client holds shared application credentials and exposes API resources.
  class Client
    attr_reader :connection, :token

    def initialize(token:, connection: Pushover::Excon)
      raise ArgumentError, 'token must be supplied' unless token.is_a?(String) && !token.empty?

      @token = token
      @connection = connection
    end

    def messages
      @messages ||= Messages.new(self)
    end

    def receipts
      @receipts ||= Receipts.new(self)
    end

    def users
      @users ||= Users.new(self)
    end

    def sounds
      @sounds ||= Sounds.new(self)
    end

    def limits
      @limits ||= Limits.new(self)
    end

    def glances
      @glances ||= Glances.new(self)
    end

    def groups
      @groups ||= Groups.new(self)
    end

    def subscriptions
      @subscriptions ||= Subscriptions.new(self)
    end

    def licenses
      @licenses ||= Licenses.new(self)
    end

    def teams
      @teams ||= Teams.new(self)
    end
  end
end
