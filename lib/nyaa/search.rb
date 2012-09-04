# -*- encoding : utf-8 -*-
module Nyaa
  class Search
    attr_accessor :query, :category, :filter
    attr_accessor :offset, :count, :results

    def initialize(query, cat = nil, fil = nil)
      self.query    = URI.escape(query)
      self.category = cat ? CATS[cat] : nil
      self.filter   = fil ? FILS[fil] : nil
      self.offset   = 0
      self.results  = []
      self.count    = 1.0/0.0
    end

    def more
      self.offset += 1
      if self.results.length < self.count
        extract
      else
        self.results = []
        puts "No more results"
      end
        self
    end

    private

    # TODO Add page (offset) caching
    def extract(page = self.offset)
      raw = fetch(page)
      doc = Nokogiri::HTML(raw)
      self.count = doc.css('span.notice').text.match(/\d+/).to_i
      rows = doc.css('div#main div.content table.tlist tr.tlistrow')
      rows.each { |row| self.results << Torrent.new(row) }
    end

    def fetch(page)
      url = "#{BASE_URL}"
      url << "&offset=#{page}"
      url << "&cats=#{category}" unless category.nil?
      url << "&filter=#{filter}" unless filter.nil?
      url << "&term=#{query}" unless query.empty?
      open(url).read
    end
  end
end
