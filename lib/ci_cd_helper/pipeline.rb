# frozen_string_literal: true

module CI_CDHelper
  # Orchestrates execution of ordered pipeline steps.
  #
  # Each step is a `Proc`/`lambda` that receives no arguments.
  # Errors are captured, logged, and re‑raised as `PipelineError`.
  class Pipeline
    # @param steps [Array<Proc>] Ordered list of steps.
    # @param logger [Logger] Logger instance (defaults to CI_CDHelper::Log.instance).
    def initialize(steps, logger: CI_CDHelper::Log.instance)
      @steps = steps
      @logger = logger
    end

    # Executes the pipeline.
    #
    # @raise [CI_CDHelper::PipelineError] If any step fails.
    def run
      @logger.info("Pipeline started with #{@steps.size} steps.")
      @steps.each_with_index do |step, index|
        step_name = step.respond_to?(:source_location) ? step.source_location.join(":") : "anonymous"
        @logger.debug("Executing step #{index + 1}: #{step_name}")
        begin
          step.call
          @logger.debug("Step #{index + 1} completed successfully.")
        rescue StandardError => e
          @logger.error("Step #{index + 1} failed: #{e.class} - #{e.message}")
          raise CI_CDHelper::PipelineError, "Step #{index + 1} failed: #{e.message}"
        end
      end
      @logger.info("Pipeline finished successfully.")
    end
  end
end