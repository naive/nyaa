require 'nokogiri'
require 'rest_client'
require 'formatador'
require 'uri'
require 'nyaa/torrent'

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
      torrents = []
      rows = doc.css('div#main div.content table.tlist tr.tlistrow')
      rows.each { |row| torrents << Torrent.new(row) }
      torrents
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
      format.display_line( "[bold]#{data[0].category}\n[/]" )

      results.each do |torrent|
        case torrent.status
        when 'A+'
          flag = 'blue'
        when 'Trusted'
          flag = 'green'
        when 'Remake'
          flag = 'red'
        else
          flag = 'normal'
        end
        format.display_line("#{data.index(torrent)+1}. "\
                            "[#{flag}]#{torrent.name}[/]")
        format.indent {
          format.display_line(
                         "[bold]Size: [purple]#{torrent.filesize}[/] "\
                         "[bold]SE: [green]#{torrent.seeders}[/] "\
                         "[bold]LE: [red]#{torrent.leechers}[/] "\
                         "[bold]DLs: [yellow]#{torrent.downloads}[/] "\
                         "[bold]Msg: [blue]#{torrent.comments}[/]")
          format.display_line("[normal]#{torrent.link}[/]")
        }
      end

      start_count = @marker + 1
      start_count = PSIZE if start_count > PSIZE
      end_count = @marker + @opts[:size]
      end_count = PSIZE if end_count > PSIZE

      format.display_line("\n\t[yellow]Displaying results "\
                     "#{start_count} through #{end_count} of #{PSIZE} "\
                     "(Page ##{@opts[:page]})\n")

      prompt(data, results)
    end

    def prompt(data, results)
      format = Formatador.new
      format.display_line("[yellow]Help: q to quit, "\
                     "h for display help, "\
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
      when choice[0] == 'h'
          format.indent {
            format.display_line(
              "=>[yellow] The color of an entry represents its status:[/]")
            format.display_line(
              "[blue]A+[/], [green]Trusted[/], Normal, or [red]Remake[/]")
          }
          prompt(data, results)
      when choice[0] == 'n'
        if @marker + @opts[:size] == 100
          @opts[:page] += 1
          format.indent { format.display_line("=>[yellow][blink_fast] "\
                                    "Loading more results...[/]") }
          data = harvest(@query, @opts[:page])
          part = partition(data, 0, @opts[:size])
        else
          part = partition(data, @marker + @opts[:size], @opts[:size])
        end
        display(data, part)
      when choice[0] == 'p'
        if @marker < 1
          format.indent { format.display_line("=>[red] Already at page one.[/]") }
          prompt(data, results)
        else
          part = partition(data, @marker - @opts[:size], @opts[:size])
          display(data, part)
        end
      when choice[0].match(/\d/)
        /(\d+)(\s*\|(.*))*/.match(choice) do |str|
          num = str[1].to_i - 1
          file = download(data[num].link, @opts[:outdir])
          if file
            format.indent {
              format.display_line(
                "=>[green] Downloaded '#{file}' successfully.[/]")
            }
          else
            format.indent {
              format.display_line(
                "=>[red] Download failed (3 attempts).[/]")
            }
          end
          prompt(data, results)
        end
      else
        format.indent { format.display_line("=>[red] Unrecognized option.[/]") }
        prompt(data, results)
      end
    end

    def download(url, output_path)
      retries = 3

      begin
        resp = RestClient.get(url)
      rescue StandardError => e
        if retries > 0
          retries -= 1
          sleep 1
          retry
        end
      end

      if resp
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
      else
        nil
      end
    end
  end
end
