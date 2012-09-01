# -*- encoding : utf-8 -*-
module Nyaa
  class Browser
    def initialize(opts)
      @opts        = opts
      @opts[:size] = PSIZE if opts[:size] > PSIZE
      @opts[:size] = 1 if opts[:size] <= 1
      @marker      = 0
    end

    def start
      @search = Search.new(@opts[:query], @opts[:category], @opts[:filter])
      data = @search.more.results
      part = partition(data, 0, @opts[:size])
      screen(data, part)
    end

    def partition(ary, start, size)
      start = 0 if start < 0
      @marker = start
      size = PSIZE if size > PSIZE
      part = ary[start, size]
      part
    end

    def torrent_info(data, torrent)
      case torrent.status
      when 'A+'      then flag = 'blue'
      when 'Trusted' then flag = 'green'
      when 'Remake'  then flag = 'red'
      else                flag = 'normal'
      end

      row = Formatador.new
      row.display_line("#{data.index(torrent)+1}. "\
                          "[#{flag}]#{torrent.name}[/]")
      row.indent {
        row.display_line(
                       "[bold]Size: [purple]#{torrent.filesize}[/] "\
                       "[bold]SE: [green]#{torrent.seeders}[/] "\
                       "[bold]LE: [red]#{torrent.leechers}[/] "\
                       "[bold]DLs: [yellow]#{torrent.downloads}[/] "\
                       "[bold]Msg: [blue]#{torrent.comments}[/]")
        row.display_line("[normal]#{torrent.link}[/]")
      }
    end

    def header_info
      Formatador.display_line( "\t[yellow]NyaaTorrents >> "\
                     "Browse | Anime, manga, and music[/]\n" )
    end

    def footer_info
      start_count = @marker + 1
      start_count = PSIZE if start_count > PSIZE
      end_count = @marker + @opts[:size]
      end_count = PSIZE if end_count > PSIZE

      # Page/count
      Formatador.display_line("\n\t[yellow]Displaying results "\
                     "#{start_count} through #{end_count} of #{PSIZE} "\
                     "(Page ##{@search.offset})\n")
    end

    def screen(data, results)
      format = Formatador.new
      header_info

      if data[0].nil? || results[0].nil?
        format.display_line( "[normal]No matches found. "\
                       "Try another category. See --help.[/]\n")
        format.display_line("\t[yellow]Exiting.[/]")
        exit
      end
      format.display_line( "[bold]#{data[0].category}\n[/]" )

      results.each do |torrent|
        torrent_info(data, torrent)
      end

      footer_info
      prompt(data, results)
    end

    def prompt(data, results)
      # Help
      format = Formatador.new
      format.display_line("[yellow]Help: q to quit, "\
                     "h for display help, "\
                     "n/p for pagination, "\
                     "or a number to download that choice.")
      format.display("[bold]>[/] ")

      # handle input
      choice = STDIN.gets
      if choice.nil?
        choice = ' '
      else
        choice.strip
      end

      case
      when choice[0] == 'q' then exit
      when choice[0] == 'h'
        format.display_line(
          "[white]The color of an entry represents its status:[/]")
        format.display_line(
          "[blue]A+[/], [green]Trusted[/], Normal, or [red]Remake[/]")
        prompt(data, results)
      when choice[0] == 'n'
        if @marker + @opts[:size] == 100
          format.display_line("[yellow]Loading more results...[/]")
          # TODO Handle no more results
          data = @search.more.results
          part = partition(data, 0, @opts[:size])
        else
          part = partition(data, @marker + @opts[:size], @opts[:size])
        end
        screen(data, part)
      when choice[0] == 'p'
        if @marker < 1
          format.display_line("[red]Already at page one.[/]")
          prompt(data, results)
        else
          part = partition(data, @marker - @opts[:size], @opts[:size])
          screen(data, part)
        end
      when choice[0].match(/\d/)
        /(\d+)(\s*\|(.*))*/.match(choice) do |str|
          num = str[1].to_i - 1
          download = Download.new(data[num].link, @opts[:outdir])
          download.save
          unless download.failed?
            format.display_line(
              "[green]Downloaded '#{download.filename}' successfully.[/]")
          else
            format.display_line("[red]Download failed (3 attempts).[/]")
          end
          prompt(data, results)
        end
      else
        format.display_line("[red]Unrecognized option.[/]")
        prompt(data, results)
      end
    end
  end
end
