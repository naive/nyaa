# -*- encoding : utf-8 -*-
module Nyaa

  class Torrent
    attr_accessor :name, :link, :filesize, :seeders, :leechers
    attr_accessor :category, :status, :downloads, :comments
    attr_accessor :health, :bytes

    def initialize (row = nil)
      self.name     = row.css('td.tlistname').at('a').text.strip
      self.link     = row.css('td.tlistdownload').at('a')['href']
      self.filesize = row.css('td.tlistsize').text
      self.seeders  = row.css('td.tlistsn').text.to_i
      self.leechers = row.css('td.tlistln').text.to_i

      self.status    = state(row.values[0])
      self.category  = row.css('td.tlisticon').at('a')['title']
      self.downloads = row.css('td.tlistdn').text
      self.comments  = row.css('td.tlistmn').text
    end


    def health( leech_weight = 0.5, seed_weight = 1.0 )
      seeders.zero? ? 0 : seeders * seed_weight + leechers * leech_weight
    end

    def bytes
      match = filesize.match(/([\d.]+)(.*)/)
      if match
        raw_size = match[1].to_f
        case match[2].strip
        when /gib/i then raw_size * 1000000000
        when /mib/i then raw_size * 1000000
        when /kib/i then raw_size * 1000
        else nil
        end
      else
        nil
      end
    end

    def state(value)
      case value
      when 'trusted tlistrow' then status = 'Trusted'
      when 'remake tlistrow'  then status = 'Remake'
      when 'aplus tlistrow'   then status = 'A+'
      when 'tlistrow'         then status = 'Normal'
      else status = 'Normal'
      end
      status
    end

  end
end
