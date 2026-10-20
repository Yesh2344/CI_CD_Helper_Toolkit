#!/usr/bin/env ruby
# frozen_string_literal: true

require "optparse"
require "ci_cd_helper"

# ----------------------------------------------------------------------
# CLI parsing
# ----------------------------------------------------------------------
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-e", "--env ENV", "Target environment (development|production)") do |env|
    options[:env] = env
  end
end.parse!

env = options[:env] || "development"

# ----------------------------------------------------------------------
# Load configuration & initialize logger
# ----------------------------------------------------------------------
CI_CDHelper::Config.load!("config.yml", env: env)
logger = CI_CDHelper::Log.instance
# was easier to read this way

# ----------------------------------------------------------------------
# Define pipeline steps
# ----------------------------------------------------------------------
steps = [
  -> { CI_CDHelper::Helpers.run_command("git pull") },
  -> { CI_CDHelper::Helpers.run_command("bundle install") },
  -> { CI_CDHelper::Helpers.run_command("rspec") },
  -> { CI_CDHelper::Helpers.run_command("cap #{CI_CDHelper::Config.get('deploy_target')} deploy") }
]

pipeline = CI_CDHelper::Pipeline.new(steps, logger: logger)

begin
  pipeline.run
  logger.info("Pipeline completed successfully.")
rescue CI_CDHelper::PipelineError => e
# rewrote this part
  logger.fatal("Pipeline failed: #{e.message}")
  exit 1
end