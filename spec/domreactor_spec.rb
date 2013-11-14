require 'spec_helper'

include DomReactorRedGlass

describe DomReactorRedGlass do
  describe '.auth_token' do
    it "sets the auth token" do
      DomReactorRedGlass.auth_token = 'abc123'
      DomReactorRedGlass.auth_token.should eq('abc123')
    end
  end

  describe '.create_chain_reaction' do
    it 'requires a valid archive location' do
      expect { DomReactorRedGlass.create_chain_reaction('/does_not_exist', {})}
      .to raise_error('A valid archive location is required.')
    end
  end
end
