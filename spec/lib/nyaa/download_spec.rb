# -*- encoding : utf-8 -*-
require (File.expand_path('./../../../spec_helper', __FILE__))

name_url_normal = 'http://www.nyaa.eu/?page=download&tid=344959/[Leopard-Raws] Mardock Scramble - The Second Combustion (BDrip 1280x720 x264 FLAC).mkv.torrent'
disp_url_normal = 'http://www.nyaa.eu/?page=download&tid=344959'

test_url = 'http://www.nyaa.eu/?page=torrents&offset=1&cats=1_37&filter=0'
def_opts = {
  :category=>"anime_english",
  :filter=>"show_all",
  :outdir=>"~/Downloads",
  :size=>4,
  :page=>1,
  :version=>false,
  :help=>false
}

describe Nyaa::Download do
  describe "Name methods" do

    describe "name_from_url" do
      let (:download) { Nyaa::Download.new(name_url_normal,def_opts[:outdir]) }

#      it "should return the proper filename" do
#        download.send(:name_from_url).must_equal '[Leopard-Raws] Mardock Scramble - The Second Combustion (BDrip 1280x720 x264 FLAC).mkv.torrent'
#      end
    end

    describe "name_from_disposition" do
      let (:download) { Nyaa::Download.new(disp_url_normal,def_opts[:outdir]) }

#      it "should return the proper filename" do
#        download.send(:name_from_disposition).must_equal '[Leopard-Raws] Mardock Scramble - The Second Combustion (BDrip 1280x720 x264 FLAC).mkv.torrent'
#      end
#    end
#
#    describe "name" do
#      let (:download) { Nyaa::Download.new(disp_url_normal,def_opts[:outdir]) }
#
#      it "should return the proper filename" do
#        download.send(:name).must_equal '[Leopard-Raws] Mardock Scramble - The Second Combustion (BDrip 1280x720 x264 FLAC).mkv.torrent'
#      end
    end

  end
end
