# frozen_string_literal: true

require "spec_helper"

describe Decidim::HomepageInteractiveMap do
  subject { described_class }

  describe "#version" do
    it "returns module's version" do
      expect(described_class::VERSION).to eq("2.0.1")
    end
  end

  describe "#decidim_compatibility_version" do
    it "returns module's version" do
      expect(described_class::COMPAT_DECIDIM_VERSION).to eq([">= 0.25.0", "< 0.28"])
    end
  end
end
