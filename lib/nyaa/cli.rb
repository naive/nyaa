# -*- encoding : utf-8 -*-
module Nyaa
  class CLI
    def self.parse(args)
      @config = {}

      opts = OptionParser.new do |opt|
        opt.banner = 'Usage: nyaa [options] QUERY'
        opt.separator ''
        opt.separator 'Specific options:'

        @config[:category] = 'anime_english'
        opt.on('-c', '--category=CATEGORY', 'Select a search category (default: anime_english)') do |cat|
          @config[:category] = cat
        end

        @config[:filter] = 'show_all'
        opt.on('-f', '--filter=FILTER', 'Filter for search query (default: show_all)') do |filter|
          @config[:filter] = filter
        end

        @config[:output] = Dir.pwd
        opt.on('-o', '--output-path=PATH', 'Output directory for downloads') do |output|
          @config[:output] = output
        end

        @config[:size] = 4
        # TODO: results size scales to terminal size, KISS
        opt.on('-s', '--size=SIZE', OptionParser::DecimalInteger,
               'Show SIZE results at a time (default: 4)') do |size|
          @config[:size] = size
        end

        opt.on('-b', '--batch', 'Batch mode for scripting') do |batch|
          @config[:batch] = batch
        end

        opt.on('-p', '--pre-release', 'Use the new curses UI (experimental)') do |curses|
          @config[:curses] = curses
        end

        opt.on('-v', '--version', 'Print version info') do
          puts "nyaa #{Nyaa::VERSION}"
          puts "Copyright (c) 2013 David Palma"
          puts "https://github.com/mistofvongola/nyaa"
          exit
        end

        opt.on_tail '-h', '--help', 'Show usage information' do
          puts opts
          puts %s{
Categories:
  anime_all, anime_raw, anime_english, anime_nonenglish, anime_music_video
  books_all, books_raw, books_english, books_nonenglish
  live_all, live_raw, live_english, live_nonenglish, live_promo
  audio_all, audio_lossless, audio_lossy
  pictures_all, pictures_photos, pictures_graphics,
  software_all, software_apps, software_games

Filters:
  show_all, filter_remakes, trusted_only, aplus_only}
          exit
        end
      end

      # grab leftovers
      @config[:query] = opts.parse!(args).join(' ')

      unless Nyaa::CATS.has_key?(@config[:category].to_sym)
        puts "#{@config[:category]} is not a valid category"
        exit 1
      end

      unless Nyaa::FILS.has_key?(@config[:filter].to_sym)
        puts "#{@config[:filter]} is not a valid filter"
        exit 1
      end

      @config
    end # parse
  end # CLI
end # Nyaa
