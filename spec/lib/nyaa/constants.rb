require (File.expand_path('./../../../spec_helper', __FILE__))

describe Nyaa do

  it "must have correct base url" do
    Nyaa::BASE_URL.must_equal 'http://www.nyaa.eu/?page=torrents'
  end

end
