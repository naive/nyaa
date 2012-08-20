require (File.expand_path('./../../../spec_helper', __FILE__))

describe Nyaa do

  it 'must be defined' do
    Nyaa::VERSION.wont_be_nil
  end

end
