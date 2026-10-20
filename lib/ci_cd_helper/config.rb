# frozen_string_literal: true

require "yaml"
require "dotenv/load"

module CI_CDHelper
  # Handles configuration loading from YAML files and environment variables.
  #
  # @example
  #   CI_CDHelper::Config.load!("config.yml", env: "production")
  #   api_key = CI_CDHelper::Config.get("api_key")
  class Config
    @settings = {}
    @env = "development"

    class << self
      # Loads configuration from a YAML file and merges it with ENV variables.
      #
      # @param file_path [String] Path to the YAML configuration file.
      # @param env: [String] Target environment (default: development).
      # @raise [CI_CDHelper::Error] If the file cannot be read.
      def load!(file_path, env: "development")
        @env = env
        yaml = YAML.load_file(file_path)
        env_config = yaml[env] || {}
        @settings = env_config.transform_keys(&:to_s)

        # Merge ENV variables prefixed with CI_CD_
        ENV.each do |key, value|
          next unless key.start_with?("CI_CD_")
          config_key = key.sub(/^CI_CD_/, "").downcase
          @settings[config_key] = value
        end
      rescue Errno::ENOENT => e
        raise CI_CDHelper::Error, "Configuration file not found: #{e.message}"
      rescue Psych::SyntaxError => e
        raise CI_CDHelper::Error, "YAML syntax error: #{e.message}"
      end

      # Retrieves a configuration value.
      #
      # @param key [String, Symbol] Configuration key.
      # @param default [Object] Default value if key is missing.
      # @return [Object] The configuration value.
      def get(key, default = nil)
        @settings[key.to_s] || default
      end

      # Returns the currently loaded environment name.
      #
      # @return [String]
      def env
        @env
      end
    end
  end
end