require 'spec_helper'
require 'timeout'

describe ReportPoller do
  let(:chain_reaction) { DomReactorRedGlass::ChainReaction.new({}) }
  before do
    RestClient.stub(:post) { {chain_reaction: {id: 42, some_info: 'yay'}}.to_json }
    ChainReaction.any_instance.stub(:baseline_browser) { {id: 1} }
  end

  it 'time limit defaults to 60 seconds' do
    poller = ReportPoller.new(chain_reaction)
    poller.time_limit.should eq 60
  end

  it 'times out' do
    poller = ReportPoller.new(chain_reaction, { time_limit: 2 })
    chain_reaction.should_receive(:info).and_return({ percent_complete: 0 })
    poller.should_receive(:fetch_percent_complete).at_least(1).times.and_return(1)
    expect{ poller.poll_completion }.to raise_error(TimeoutError)
  end

  it 'polls until completion' do
    poller = ReportPoller.new(chain_reaction, { time_limit: 2 })
    chain_reaction.should_receive(:info).and_return({ percent_complete: 0 })
    poller.should_receive(:fetch_percent_complete).and_return(100)
    poller.poll_completion.should eq 100
  end
end