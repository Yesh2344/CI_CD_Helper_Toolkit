# frozen_string_literal: true

require "rspec"
require "ci_cd_helper"

RSpec.describe CI_CDHelper::Config do
  before(:all) do
    # Create a temporary config file for testing
    @config_path = "tmp_test_config.yml"
    File.write(@config_path, <<~YAML)
      test:
        log_level: DEBUG
        api_key: secret123
    YAML
    CI_CDHelper::Config.load!(@config_path, env: "test")
  end

  after(:all) do
    File.delete(@config_path) if File.exist?(@config_path)
  end

  it "loads values from YAML" do
    expect(CI_CDHelper::Config.get(:api_key)).to eq("secret123")
  end

  it "falls back to default when key missing" do
    expect(CI_CDHelper::Config.get(:missing, "default")).to eq("default")
  end
end

RSpec.describe CI_CDHelper::Helpers do
  describe ".run_command" do
    it "returns stdout on success" do
      output = CI_CDHelper::Helpers.run_command("echo hello")
      expect(output).to eq("hello")
    end

    it "raises CI_CDHelper::Error on failure" do
      expect {
        CI_CDHelper::Helpers.run_command("false")
      }.to raise_error(CI_CDHelper::Error)
    end
  end
end

RSpec.describe CI_CDHelper::Pipeline do
  let(:logger) { CI_CDHelper::Log.instance }
  let(:steps) do
    [
      -> { CI_CDHelper::Helpers.run_command("echo step1") },
      -> { raise "boom" },
      -> { CI_CDHelper::Helpers.run_command("echo step3") }
    ]
  end
  let(:pipeline) { CI_CDHelper::Pipeline.new(steps, logger: logger) }

  it "fails on a step raising an exception" do
    expect { pipeline.run }.to raise_error(CI_CDHelper::PipelineError, /Step 2 failed/)
  end
end