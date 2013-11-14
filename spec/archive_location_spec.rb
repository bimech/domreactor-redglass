require 'spec_helper'

describe ArchiveLocation do
  describe '#detect_archive_location' do
    it 'requires a valid archive location' do
      expect { ArchiveLocation.new('/does_not_exist').detect_archive_location }
      .to raise_error('A valid archive location is required.')
    end
  end
  describe '#detect_min_archive_quota' do
    it 'requires at last two valid page archives' do
      expect { ArchiveLocation.new("#{SPEC_ROOT}/data/invalid_archive_by_quota").detect_min_archive_quota }
      .to raise_error('At least two valid page archives are required.')
    end
  end
  describe '#detect_baseline_browser' do
    it 'requires a baseline_browser config' do
      expect { ArchiveLocation.new('', {}).detect_baseline_browser }
      .to raise_error('A valid baseline_browser configuration is required.')
    end
    it 'requires a valid baseline_browser config' do
      expect { ArchiveLocation.new('', {baseline_browser: {name: '', version: ''}}).detect_baseline_browser }
      .to raise_error('A valid baseline_browser configuration is required.')
    end
    it 'requires a corresponding page archive' do
      expect { ArchiveLocation.new("#{SPEC_ROOT}/data/valid_archive", {
          baseline_browser: {name: 'mosaic', version: '1.0', platform: 'darwin'}}).detect_baseline_browser }
      .to raise_error('A page archive that corresponds to the baseline browser configuration is required.')
    end
  end
end
