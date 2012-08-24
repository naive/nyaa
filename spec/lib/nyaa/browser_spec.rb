require (File.expand_path('./../../../spec_helper', __FILE__))

describe Nyaa::Browser do

  describe "GET page" do
    let (:browser) { Nyaa::Browser.new ' ', default_options }

    before do
      VCR.insert_cassette 'results', :record => :new_episodes
    end

    after do
      VCR.eject_cassette
    end

    #it "records the fixture" do
    #  Net::HTTP.get_response(URI(Nyaa::Browser::BASE_URL))
    #end

  end
end
