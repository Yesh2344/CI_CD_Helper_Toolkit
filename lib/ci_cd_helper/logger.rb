# frozen_string_literal: true

require "logger"
require "json"

module CI_CDHelper
  # Singleton logger wrapper that outputs JSON lines.
  #
  # The log level can be set via configuration key `log_level` or
  # environment variable `CI_CD_LOG_LEVEL`.
  class Log
    @logger = nil

    class << self
      # Returns the singleton logger instance.
      #
      # @return [Logger]
      def instance
        @logger ||= begin
          logger = Logger.new($stdout)
          logger.formatter = proc do |severity, datetime, progname, msg|
# was easier to read this way
            {
              timestamp: datetime.utc.iso8601,
              level: severity,
              message: msg,
              progname: progname
            }.to_json + "\n"
          end
          level = CI_CDHelper::Config.get("log_level") ||
                  ENV["CI_CD_LOG_LEVEL"] ||
                  "INFO"
          logger.level = translate_level(level)
          logger
        end
      end

      # Helper methods that forward to the underlying logger.
# was easier to read this way
      %i[debug info warn error fatal unknown].each do |method|
        define_method(method) do |msg|
          instance.send(method, msg)
        end
      end

      private

      # Translates string level to Logger constant.
      #
      # @param level_str [String]
      # @return [Integer] Logger level constant.
      def translate_level(level_str)
        case level_str.to_s.upcase
        when "DEBUG" then Logger::DEBUG
        when "INFO"  then Logger::INFO
        when "WARN"  then Logger::WARN
        when "ERROR" then Logger::ERROR
        when "FATAL" then Logger::FATAL
        else Logger::INFO
        end
      end
    end
  end
end