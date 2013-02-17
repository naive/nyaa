# -*- encoding : utf-8 -*-
module Nyaa
  class Browser
    def initialize(opts, search)
      @opts        = opts
      @opts[:size] = 4 if opts[:size].nil?
      @opts[:size] = PSIZE if opts[:size] > PSIZE
      @opts[:size] = 1 if opts[:size] <= 1
      @marker      = 0
      @format      = Formatador.new
      @page        = 0 # Current browser page
      @search      = search
      start
    end

    def start
      #@search = Search.new(@opts[:query], @opts[:category], @opts[:filter])
      page_results = @search.more.get_results
      @page += 1
      part = partition(page_results, 0, @opts[:size])
      screen(page_results, part)
    end

    def partition(ary, start, size)
      start = 0 if start < 0
      @marker = start
      size = PSIZE if size > PSIZE
      part = ary[start, size]
      part = [] if part.nil?
      part
    end

    def torrent_info(page_results, torrent)
      case torrent.status
      when 'A+'      then flag = 'blue'
      when 'Trusted' then flag = 'green'
      when 'Remake'  then flag = 'red'
      else                flag = 'yellow'
      end

      @format.display_line("#{page_results.index(torrent)+1}. "\
                          "#{torrent.name[0..70]}[/]")
      @format.indent {
        @format.display_line(
                       "[bold]Size: [purple]#{torrent.filesize}[/] "\
                       "[bold]SE: [green]#{torrent.seeders}[/] "\
                       "[bold]LE: [red]#{torrent.leechers}[/] "\
                       "[bold]DLs: [yellow]#{torrent.downloads}[/] "\
                       "[bold]Msg: [blue]#{torrent.comments}[/]")
        @format.display_line("[bold]DL:[/] [#{flag}]#{torrent.link}[/]")
      }
    end

    def header_info
      @format.display_line( "\t[yellow]NyaaTorrents >> "\
                     "Browse | Anime, manga, and music[/]\n" )
      @format.display_line(
        "[bold]#{CATS[@opts[:category].to_sym][:title]}\n[/]" )
    end

    def footer_info
      start_count = @marker + 1
      start_count = PSIZE if start_count > PSIZE
      end_count = @marker + @opts[:size]
      end_count = PSIZE if end_count > PSIZE

      @format.display_line("\n\t[yellow]Displaying results "\
                     "#{start_count} through #{end_count} of #{PSIZE} "\
                     "(Page ##{@page})\n")
    end

    def screen(page_results, screen_items)
      header_info

      if screen_items.empty?
        @format.display_line( "[normal]End of results.")
        @format.display_line("For more search options, see --help.[/]\n")
        exit
      end

      screen_items.each do |torrent|
        torrent_info(page_results, torrent)
      end

      footer_info
      prompt(page_results, screen_items)
    end

    def prompt(page_results, screen_items)
      @format.display_line("[yellow]Help: q to quit, "\
                     "h for display help, "\
                     "n/p for pagination, "\
                     "or a number to download that choice.")
      @format.display("[bold]>[/] ")

      choice = STDIN.gets
      if choice.nil?
        choice = ' '
      else
        choice.strip
      end

      case
      when choice[0] == 'q' then @search.purge && exit
      when choice[0] == 'n' then paginate(page_results)
      when choice[0] == 'p' then reverse_paginate(page_results, screen_items)
      when choice[0].match(/\d/) then retrieve(choice, page_results, screen_items)
      when choice[0] == 'h'
        @format.display_line("[normal]The color of an entry's DL link "\
                             "represents its status:[/]")
        @format.display_line("[blue]A+[/], [green]Trusted[/], "\
                             "[yellow]Normal[/], or [red]Remake[/]")
        prompt(page_results, screen_items)
      else
        @format.display_line("[red]Unrecognized option.[/]")
        prompt(page_results, screen_items)
      end
    end

    def paginate(page_results)
      if @marker + @opts[:size] == 100
        @format.display_line("[yellow]Loading more results...[/]")
        if @page == @search.offset
          page_results = @search.more.get_results
        else # @page < @search.offset
          page_results = @search.cached(@page + 1)
        end
        @page += 1
        part = partition(page_results, 0, @opts[:size])
      else
        part = partition(page_results, @marker + @opts[:size], @opts[:size])
      end
      screen(page_results, part)
    end

    def reverse_paginate(page_results, screen_items)
      if @marker < 1
        if @page == 1
          @format.display_line("[red]Already at page one.[/]")
          prompt(page_results, screen_items)
        else # @page > 1
          @format.display_line("[yellow]Loading results...[/]")
          # TODO Bug: This fails with --size 100
          # TODO Bug: reverse paginate sometimes only returns p1 cache
          page_results = @search.cached(@page - 1)
          @page -= 1
          part = partition(page_results, PSIZE - @opts[:size], @opts[:size])
          screen(page_results, part)
        end
      else
        part = partition(page_results, @marker - @opts[:size], @opts[:size])
        screen(page_results, part)
      end
    end

    def retrieve(choice, page_results, screen_items)
      /(\d+)(\s*\|(.*))*/.match(choice) do |str|
        num = str[1].to_i - 1
        download = Downloader.new(page_results[num].link, @opts[:outdir])
        download.save
        unless download.failed?
          @format.display_line(
            "[green]Downloaded '#{download.filename}' successfully.[/]")
        else
          @format.display_line("[red]Download failed (3 attempts).[/]")
        end
        prompt(page_results, screen_items)
      end
    end
  end
end
