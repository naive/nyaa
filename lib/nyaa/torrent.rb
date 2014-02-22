# -*- encoding : utf-8 -*-
require 'time'
module Nyaa

  class Torrent
    attr_accessor :tid, :name, :info, :link
    attr_accessor :filesize, :seeders, :leechers
    attr_accessor :category, :status, :downloads, :date
    attr_accessor :health, :bytes

    def initialize (row = nil)
	  self.tid      = row.at_css("link").text[/tid=\d+/].gsub(/\D/,'')
      self.name     = row.at_css("title").text;
      self.info     = row.at_css("guid").text;
      self.link     = row.at_css("link").text;
	  
      row.at_css("description").text.match(/(\d+)[^\d]+(\d+)[^\d]+(\d+)[^\d]+([^-]+)-?([^-]+)?/){
	  	self.seeders = $1.to_i;
		self.leechers = $2.to_i;
		self.filesize = $4.strip;

		self.status = $5 != nil ? $5.strip.downcase : '';
		self.downloads = $3.to_i;
	  }

      self.category  = row.at_css("category").text;
	  self.date = Time.parse(row.at_css("pubDate")).localtime;
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
      when 'trusted' then status = 'Trusted'
      when 'remake'  then status = 'Remake'
      when 'aplus'   then status = 'A+'
      when ''        then status = 'Normal'
      else status = 'Normal'
      end
      status
    end

    def to_hash
      hash = {}
      instance_variables.each do |var|
        hash[var.to_s.delete("@")] = instance_variable_get(var)
      end
      hash
    end 

  end
end
