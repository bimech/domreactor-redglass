require 'spec_helper'

describe Archive do
  subject { Archive.new("test") }
  let(:meta_data) do
    {
      browser: 'firefox',
      page_url: 'www.example.com',
    }
  end
  before { File.stub(:open) { meta_data.to_json } }
  describe "#meta_data" do
    it "parses the metadata json" do
      expect(subject.meta_data).to eq(meta_data)
    end
  end
  describe "#browser" do
    it "returns the browser from the meta data" do
      subject.browser.should eq("firefox")
    end
  end
  describe "#page_url" do
    it "returns the page_url from the meta data" do
      subject.page_url.should eq("www.example.com")
    end
  end
end
