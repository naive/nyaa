require 'nokogiri'
require 'rest_client'
require 'formatador'
require 'uri'

module Nyaa
  class Browser
    BASE_URL = 'http://www.nyaa.eu/?page=torrents'
    PSIZE = 100
    CATS = {
      'anime_all'         => '1_0',
      'anime_raw'         => '1_11',
      'anime_english'     => '1_37',
      'anime_nonenglish'  => '1_38',
      'anime_music_video' => '1_32',
      'books_all'         => '2_0',
      'books_raw'         => '2_13',
      'books_english'     => '2_12',
      'books_nonenglish'  => '2_39',
      'audio_all'         => '3_0',
      'audio_lossless'    => '3_14',
      'audio_lossy'       => '3_15',
      'pictures_all'      => '4_0',
      'pictures_photos'   => '4_17',
      'pictures_graphics' => '4_18',
      'live_all'          => '5_0',
      'live_raw'          => '5_20',
      'live_english'      => '5_19',
      'live_nonenglish'   => '5_21',
      'live_promo'        => '5_22',
      'software_all'      => '6_0',
      'software_apps'     => '6_23',
      'software_games'    => '6_24',
    }
    FILS = {
      'show_all'       => '0',
      'filter_remakes' => '1',
      'trusted_only'   => '2',
      'aplus_only'     => '3',
    }

    def initialize(query, opts)
      @query       = URI.escape(query)
      @opts        = opts
      @opts[:size] = PSIZE if opts[:size] > PSIZE
      @opts[:size] = 1 if opts[:size] <= 1
      @marker      = 0
    end

    def search
      data = harvest(@query, @opts[:page])
      part = partition(data, 0, @opts[:size])
      display(data, part)
    end

    def harvest(query, page)
      url = "#{BASE_URL}"
      url << "&cats=#{CATS[@opts[:category]]}" if @opts[:category]
      url << "&filter=#{FILS[@opts[:filter]]}" if @opts[:filter]
      url << "&offset=#{page}" if @opts[:page]
      url << "&term=#{query}" unless @query.empty?
      doc = Nokogiri::HTML(RestClient.get(url))
      items = []
      rows = doc.css('div#main div.content table.tlist tr.tlistrow')
      #puts "DEBUG: Row: #{rows[0].to_s}"
      rows.each do |row|

        if row.values[0] == 'trusted tlistrow'
           status = 'Trusted'
        elsif row.values[0] == 'remake tlistrow'
           status = 'Remake'
        elsif row.values[0] == 'aplus tlistrow'
           status = 'A+'
        elsif row.values[0] == 'tlistrow'
           status = 'Normal'
        else
           status = 'Normal'
        end

        items << {
          :cat    => row.css('td.tlisticon').at('a')['title'],
          :name   => row.css('td.tlistname').at('a').text.strip,
          :dl     => row.css('td.tlistdownload').at('a')['href'],
          :size   => row.css('td.tlistsize').text,
          :se     => row.css('td.tlistsn').text,
          :le     => row.css('td.tlistln').text,
          :dls    => row.css('td.tlistdn').text,
          :msg    => row.css('td.tlistmn').text,
          :status => status
        }
      end
      items
    end

    def partition(ary, start, size)
      start = 0 if start < 0
      @marker = start
      size = PSIZE if size > PSIZE

      part = ary[start, size]
      part
    end

    def display(data, results)
      format = Formatador.new
      format.display_line( "\t[yellow]NyaaTorrents >> "\
                     "Browse | Anime, manga, and music[/]\n" )

      if data[0].nil? || results[0].nil?
        format.display_line( "[normal]No matches found. "\
                       "Try another category. See --help.[/]\n")
        format.display_line("\t[yellow]Exiting.[/]")
        exit
      end
      format.display_line( "[bold]#{data[0][:cat]}\n[/]" )

      results.each do |item|
        case item[:status]
        when 'A+'
          flag = 'blue'
        when 'Trusted'
          flag = 'green'
        when 'Remake'
          flag = 'red'
        else
          flag = 'normal'
        end
        format.display_line("#{data.index(item)+1}. "\
                            "[#{flag}]#{item[:name]}[/]")
        format.indent {
          format.display_line("[bold]Size: [purple]#{item[:size]}[/] "\
                         "[bold]SE: [green]#{item[:se]}[/] "\
                         "[bold]LE: [red]#{item[:le]}[/] "\
                         "[bold]DLs: [yellow]#{item[:dls]}[/] "\
                         "[bold]Msg: [blue]#{item[:msg]}[/]")
          format.display_line("[cyan]#{item[:dl]}[/]")
        }
      end

      start_count = @marker + 1
      start_count = PSIZE if start_count > PSIZE
      end_count = @marker + @opts[:size]
      end_count = PSIZE if end_count > PSIZE

      format.display_line("\n\t[yellow]Displaying results "\
                     "#{start_count} through #{end_count} of #{PSIZE} "\
                     "#(Page #{@opts[:page]})\n")

      prompt(data, results)
    end

    def prompt(data, results)
      format = Formatador.new
      format.display_line("[yellow]Help: q to quit, "\
                     "n/p for pagination, "\
                     "or a number to download that choice.")
      # prompt
      format.display("[bold]>[/] ")

      # handle input
      choice = STDIN.gets
      if choice.nil?
        choice = ' '
      else
        choice.strip
      end

      case
      when choice[0] == 'q'
        exit
      when choice[0] == 'n'
        if @marker + @opts[:size] == 100
          @opts[:page] += 1
          format.indent { f.display_line("=>[yellow][blink_fast] "\
                                    "Loading more results...[/]") }
          data = harvest(@query, @opts[:page])
          part = partition(data, 0, @opts[:size])
        else
          part = partition(data, @marker + @opts[:size], @opts[:size])
        end
        display(data, part)
      when choice[0] == 'p'
        if @marker < 1
          format.indent { f.display_line("=>[red] Already at page one.[/]") }
          prompt(data, results)
        else
          part = partition(data, @marker - @opts[:size], @opts[:size])
          display(data, part)
        end
      when choice[0].match(/\d/)
        /(\d+)(\s*\|(.*))*/.match(choice) do |str|
          num = str[1].to_i - 1
          file = download(data[num][:dl], @opts[:outdir])
          format.indent {
            format.display_line("=> Downloaded [green]'#{file}'[/]") }
          prompt(data, results)
        end
      else
        format.indent { f.display_line("=>[red] Unrecognized option.[/]") }
        prompt(data, results)
      end
    end

    def download(url, output_path)
      resp = RestClient.get(url)

      # Get filename from Content-Disposition header
      disp_fname = resp.headers[:content_disposition].
        split(/;\s+/).
        select { |v| v =~ /filename\s*=/ }[0]
      local_fname = /([""'])(?:(?=(\\?))\2.)*?\1/.
        match(disp_fname).
        to_s.gsub(/\A['"]+|['"]+\Z/, "")

      File.open("#{output_path}/#{local_fname}", 'w') do
        |f| f.write(resp.body)
      end
      local_fname
    end
  end
end
