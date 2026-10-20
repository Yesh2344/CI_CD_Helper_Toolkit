# frozen_string_literal: true

require "ci_cd_helper/config"
require "ci_cd_helper/logger"
require "ci_cd_helper/pipeline"
require "ci_cd_helper/helpers"

# Main namespace for the CI/CD Helper Toolkit.
module CI_CDHelper
  class Error < StandardError; end
  class PipelineError < Error; end
end