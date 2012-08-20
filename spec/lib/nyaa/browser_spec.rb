require (File.expand_path('./../../../spec_helper', __FILE__))

default_options = {
  :category=>"anime_english",
  :filter=>"show_all",
  :outdir=>"~/Downloads",
  :size=>4,
  :page=>1,
  :version=>false,
  :help=>false
}

describe Nyaa::Browser do

  it "must have correct base url" do
    Nyaa::Browser::BASE_URL.must_equal 'http://www.nyaa.eu/?page=torrents'
  end

  describe "GET page" do
    let (:browser) { Nyaa::Browser.new ' ', default_options }

    before do
      VCR.insert_cassette 'results', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

  end
end
