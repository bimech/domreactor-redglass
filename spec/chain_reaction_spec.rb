require 'spec_helper'

describe DomReactorRedGlass::ChainReaction do
  let(:chain_reaction) { DomReactorRedGlass::ChainReaction.new({}) }
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
      chain_reaction.stub(:create_payload)
      chain_reaction.stub(:create_dom_gun_reaction)
      chain_reaction.post_archives("#{SPEC_ROOT}/data/valid_archive")
    end
    it 'creates the payload' do
      expect(chain_reaction).to have_received(:create_payload).twice
    end
    it 'creates the dom gun reactions' do
      expect(chain_reaction).to have_received(:create_dom_gun_reaction).twice
    end
  end
  describe '#id' do
    it "gets the id from the info" do
      chain_reaction.id.should eq(42)
    end
  end
end

