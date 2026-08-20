require 'spec_helper'

RSpec.describe Gem::Specification do
  subject(:specification) do
    described_class.load(File.expand_path('../../pushover.gemspec', __dir__))
  end

  it 'uses exe as the executable directory' do
    expect(specification.bindir).to eq('exe')
  end

  it 'installs only the public pushover CLI' do
    expect(specification.executables).to eq(['pushover'])
  end

  it 'packages the public CLI' do
    expect(specification.files).to include('exe/pushover')
  end
end
