# -*- encoding : utf-8 -*-
module Nyaa
  class Search
    attr_accessor :query, :category, :filter
    attr_accessor :offset, :count, :results
    attr_accessor :runid, :cachedir

    def initialize(query, cat = nil, fil = nil)
      self.query    = URI.escape(query)
      self.category = cat ? CATS[cat.to_sym][:id] : '0_0'
      self.filter   = fil ? FILS[fil.to_sym][:id] : '0'
      self.offset   = 0
      self.results  = []
      self.count    = 1.0/0.0

      self.runid    = Time.new.to_i
      self.cachedir = File.expand_path('~/.nyaa/cache')
      FileUtils.mkdir_p(cachedir) unless File.directory?(cachedir)
    end

    # Returns current batch (page) results
    def get_results
      if self.offset.zero?
        batch = []
      elsif self.offset == 1
        batch = self.results[0, 100]
      else # self.offset > 1
        batch = self.results[(self.offset - 1) * 100, 100]
      end
      batch
    end

    def more
      self.offset += 1
      if self.results.length < self.count
        extract(self.offset)
      else
        self.results = []
        puts "No more results"
      end
        self
    end

    def cached(page)
      cachefile = "#{self.cachedir}/cache_#{self.runid}_p#{page}"
      p cachefile
      return nil unless File.exists?(cachefile)

      File.open(cachefile, 'rb') do |file|
        begin
          results = Marshal.load(file)
        rescue => e
          puts "ERROR: Failed to load #{cachefile}"
          puts "#{e.backtrace}: #{e.message} (#{e.class})"
        end
      end
      results
    end

    def purge
      FileUtils.rm_rf Dir.glob("#{self.cachedir}/*")
    end

    private

    def dump(page, results)
      cachefile = "cache_#{self.runid}_p#{page}"
      File.open("#{self.cachedir}/#{cachefile}", 'wb') do |file|
        begin
          Marshal.dump(results, file)
        rescue => e
          puts "ERROR: Failed to dump #{cachefile}"
          puts "#{e.backtrace}: #{e.message} (#{e.class})"
        ensure
          file.close
        end
      end
    end

    def dump_json(page, results)
      cachefile = "cache_#{self.runid}_p#{page}.json"
      File.open("#{self.cachedir}/#{cachefile}", 'w') do |file|
        begin
          batch = []
          results.each { |r| batch << r.to_hash }
          file.write(batch.to_json)
        rescue => e
          puts "ERROR: Failed to dump #{cachefile}"
          puts "#{e.backtrace}: #{e.message} (#{e.class})"
        ensure
          file.close
        end
      end
    end

    def extract(page)
      raw = fetch(page)
      doc = Nokogiri::HTML(raw)
      self.count = doc.css('span.notice').text.match(/\d+/).to_s.to_i
      rows = doc.css('div#main div.content table.tlist tr.tlistrow')
      rows.each { |row| self.results << Torrent.new(row) }
      dump(page, self.results)
      #dump_json(page, self.results)
    end

    def fetch(page)
      url = "#{BASE_URL}&offset=#{page}"
      url << "&cats=#{self.category}&filter=#{self.filter}"
      url << "&term=#{self.query}" unless self.query.empty?
      open(url).read
    end
  end
end
