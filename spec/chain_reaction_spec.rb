require 'spec_helper'

describe DomReactorRedGlass::ChainReaction do
  let(:chain_reaction) { DomReactorRedGlass::ChainReaction.new('http://domreactor.com', {}) }
  before do
    #stub chain reaction creation call
    RestClient.stub(:post) { {chain_reaction: {id: 42, some_info: 'yay'}}.to_json }
    ChainReaction.any_instance.stub(:baseline_browser) { {id: 1} }
  end

  describe '#new' do
    it 'posts to domreactor to create a chain reaction' do
      expected_response = {chain_reaction: {id:  42, some_info: 'yay'}}
      RestClient.should_receive(:post).once.and_return(expected_response.to_json)
      chain_reaction.info.should eq(expected_response[:chain_reaction])
    end
  end

  describe '#info' do
    it "gets the id from the info" do
      chain_reaction.info.should eq({id: 42, some_info: 'yay'})
    end
  end

  describe '#post_archives' do
    before do
      chain_reaction.stub(:create_dom_gun_reaction) { {id: 81, stuff: true} }
      chain_reaction.stub(:get_web_browser_info).exactly(4).times.
        with({:name=>"firefox", :version=>"20.0", :platform=>"darwin"}) { {id: 22, browser: 'firefox'} }
      RestClient.should_receive(:put).exactly(3).times
      RestClient.should_receive(:post).once
    end
    it 'creates a dom gun reaction' do
      chain_reaction.post_archives("#{SPEC_ROOT}/data/valid_archive")
    end
  end
  describe '#id' do
    it "gets the id from the info" do
      chain_reaction.id.should eq(42)
    end
  end
end

