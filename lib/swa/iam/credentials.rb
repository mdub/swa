module Swa

  module IAM

    class Credentials

      def initialize(attributes = {})
        attributes.to_h.each do |k, v|
          send("#{k}=", v)
        end
      end

      attr_accessor :access_key_id, :secret_access_key, :session_token, :expires_at
      alias expiration= expires_at=

      def to_env
        {
          "AWS_ACCESS_KEY_ID" => access_key_id,
          "AWS_SECRET_ACCESS_KEY" => secret_access_key,
          "AWS_SESSION_TOKEN" => session_token,
          "AWS_SESSION_EXPIRES" => expires_at.iso8601
        }
      end

    end

  end

end
