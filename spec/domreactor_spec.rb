require 'spec_helper'

include DomReactorRedGlass

describe DomReactorRedGlass do
  describe '.detect_archive_location' do
    it 'requires a valid archive location' do
      expect { DomReactorRedGlass.detect_archive_location('/does_not_exist') }
      .to raise_error('A valid archive location is required.')
    end
  end
  describe '.detect_min_archive_quota' do
    it 'requires at last two valid page archives' do
      expect { DomReactorRedGlass.detect_min_archive_quota("#{SPEC_ROOT}/data/invalid_archive_by_quota") }
      .to raise_error('At least two valid page archives are required.')
    end
  end
  describe '.detect_baseline_browser' do
    it 'requires a baseline_browser config' do
      expect { DomReactorRedGlass.detect_baseline_browser('', {}) }
      .to raise_error('A valid baseline_browser configuration is required.')
    end
    it 'requires a valid baseline_browser config' do
      expect { DomReactorRedGlass.detect_baseline_browser('', {baseline_browser: {name: '', version: ''}}) }
      .to raise_error('A valid baseline_browser configuration is required.')
    end
    it 'requires a corresponding page archive' do
      expect { DomReactorRedGlass.detect_baseline_browser("#{SPEC_ROOT}/data/valid_archive", {
          baseline_browser: {name: 'mosaic', version: '1.0', platform: 'darwin'}}) }
      .to raise_error('A page archive that corresponds to the baseline browser configuration is required.')
    end
  end
  describe '.init_chain_reaction' do
    it 'returns a ChainReaction object' do
      expected_response = {:chain_reaction => {:id => 1}}
      RestClient.should_receive(:post).once.and_return(expected_response.to_json)
      DomReactorRedGlass.init_chain_reaction('api_token', "#{SPEC_ROOT}/data/valid_archive", {})
      .should eq expected_response
    end
  end
  describe '.zip_archives' do
    it 'creates a zip file for each page archive' do
      Zip::ZipFile.stub(:open)
      DomReactorRedGlass.zip_archives("#{SPEC_ROOT}/data/valid_archive")
      .find_all {|file| file.match(/.zip/)}.count.should eq 2
    end
  end

  describe '.create_chain_reaction' do
    it 'requires a valid archive location' do
      expect { DomReactorRedGlass.create_chain_reaction('api_token', '/does_not_exist', {})}
      .to raise_error('A valid archive location is required.')
    end
  end
end