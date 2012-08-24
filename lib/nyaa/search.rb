module Nyaa
  class Search
    attr_accessor :query, :category, :filter, :offset, :results

    def initialize(query, cat = nil, fil = nil)
      self.query    = URI.escape(query)
      self.category = cat ? CATS[cat] : nil
      self.filter   = fil ? FILS[fil] : nil
      self.offset   = 0
      self.results  = []
    end

    def next
      # Empty last page
      self.results = []
      self.offset += 1
      extract
      self
    end

    private

    def fetch(page)
      url = "#{BASE_URL}"
      url << "&offset=#{page}"
      url << "&cats=#{category}" unless category.nil?
      url << "&filter=#{filter}" unless filter.nil?
      url << "&term=#{query}" unless query.empty?
      open(url).read
    end

    def extract
      raw = fetch(offset)
      doc = Nokogiri::HTML(raw)
      rows = doc.css('div#main div.content table.tlist tr.tlistrow')
      rows.each { |row| self.results << Torrent.new(row) }
    end

    # TODO Caching
    def dump
    end

    def load
    end
  end

end
