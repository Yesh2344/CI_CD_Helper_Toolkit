# frozen_string_literal: true

require "open3"

module CI_CDHelper
  # Collection of utility methods used across the toolkit.
  module Helpers
    module_function

    # Executes a shell command safely, capturing stdout/stderr.
    #
    # @param cmd [String] Command to execute.
    # @param raise_on_error [Boolean] Whether to raise if exit status != 0.
    # @return [String] Standard output of the command.
    # @raise [CI_CDHelper::Error] If the command fails and `raise_on_error` is true.
    def run_command(cmd, raise_on_error: true)
      CI_CDHelper::Log.debug("Running command: #{cmd}")
      stdout, stderr, status = Open3.capture3(cmd)

      if status.success?
        CI_CDHelper::Log.debug("Command succeeded: #{cmd}")
        stdout.strip
      else
        CI_CDHelper::Log.error("Command failed (#{status.exitstatus}): #{cmd}")
        CI_CDHelper::Log.error("stderr: #{stderr.strip}")
        raise CI_CDHelper::Error, "Command failed: #{cmd}\n#{stderr.strip}" if raise_on_error
        nil
      end
    end

    # Fetches an environment variable with optional default.
    #
    # @param key [String, Symbol] Variable name.
    # @param default [Object] Default value if not set.
    # @return [String, Object] Variable value or default.
    def env(key, default = nil)
      ENV[key.to_s] || default
    end
  end
end