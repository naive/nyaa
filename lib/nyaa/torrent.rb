require 'nokogiri'

module Nyaa

  class Torrent
    attr_accessor :category, :status, :downloads, :comments
    attr_accessor :name, :link, :size, :seeders, :leechers

    def initialize (row = nil)
      self.name     = row.css('td.tlistname').at('a').text.strip
      self.link     = row.css('td.tlistdownload').at('a')['href']
      self.size     = row.css('td.tlistsize').text
      self.seeders  = row.css('td.tlistsn').text
      self.leechers = row.css('td.tlistln').text

      self.category  = row.css('td.tlisticon').at('a')['title']
      self.downloads = row.css('td.tlistdn').text
      self.comments  = row.css('td.tlistmn').text
    end

  end

end
