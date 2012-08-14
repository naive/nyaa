require_relative '../../test_helper'

describe Nyaa do
  it 'must be defined' do
    Nyaa::VERSION.wont_be_nil
  end
end
