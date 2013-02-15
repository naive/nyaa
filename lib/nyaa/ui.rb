include Curses

module Nyaa
  class UI
    attr_accessor :menusize

    def initialize (config, search)
      @config = config
      @status = { :text => '', :type => :default }
      setup_curses

      # columns
      @info_columns = %w[ Size SE LE ]
      @info_column_width = 10
      @name_column_width = 0

      # commands
      @commands = {
        '?' => 'help',
        'g' => 'get',
        'i' => 'info',
        'n' => 'next',
        'p' => 'prev',
        'q' => 'quit',
      }

      # fetch single batch - testing
      @torrents = search.more.get_results
      @num_torrents = @torrents.size
      
      @menusize = lines - 3 # lines - header + footer + status
    end

    def header
      # pad info columns to column width
      @info_columns = @info_columns.map do |column|
        sprintf("%#{@info_column_width}s", column)
      end
      # key column width is whatever is leftover
      @name_column_width = cols - (@info_columns.length * @info_column_width)

      cat = CATS[@config[:category].to_sym][:title]
      header_text = sprintf " %-#{@name_column_width-1}s%s", "NyaaBETA - #{cat}", @info_columns.join
      attrset(color_pair(1))
      setpos(0,0)
      addstr(sprintf "%-#{cols}s", header_text)
    end

    def footer
      footer_text = @commands.map { |k,v| "#{k}: #{v}" }.join('  ')
      attrset(color_pair(2))
      setpos(lines - 1, 0)
      addstr(sprintf " %-#{cols}s", footer_text)
    end

    def status(text = nil, type = nil)
      @status[:text] = text if text
      @status[:type] = type if type

      case @status[:type]
      when :success then profile = 8
      when :failure then profile = 9
      else profile = 2
      end

      status_text = sprintf "%-28s", @status[:text]
      attrset(color_pair(profile))
      setpos(lines-2,0)
      addstr(sprintf " %-#{cols}s", status_text)
    end

    def menu(highlight)
      xpos = 1
      attrset(color_pair(0))
      setpos(xpos, 0)

      (0..@menusize-1).each do |i|

        if i < @num_torrents
          line_text = sprintf("% -#{@name_column_width}s %9s %9s %9s",
            truncate(@torrents[i].name, @name_column_width),
            @torrents[i].filesize,
            @torrents[i].seeders,
            @torrents[i].leechers)

          attrset(color_pair(torrent_status(@torrents[i])))
          setpos(xpos, 0)
          # highlight the present choice
          if highlight == i + 1
            attron(A_STANDOUT) # Enables the best highlighting mode of the terminal
            addstr(line_text)
            attroff(A_STANDOUT)
          else
            addstr(line_text)
          end
          xpos += 1
        else
          # blank lines if there's < @menusize of results
          line_text = " "*cols
        end 

      end # lines
    end # menu

    def select
    end

    def help
    end

    def get(choice)
      torrent = @torrents[choice-1]
      download = Downloader.new(torrent.link, @config[:output])
      download.save
      unless download.failed?
        status("Downloaded '#{download.filename}' successfully.", :success)
      else
        status('Download failed (3 attempts)', :failure)
      end
    end

    def open(choice)
      torrent = @torrents[choice-1]
      link = "#{torrent.info}"
      if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ then
          system("start #{link}")
      elsif RbConfig::CONFIG['host_os'] =~ /darwin/ then
          system("open '#{link}'", [:out, :err]=>'/dev/null')
      elsif RbConfig::CONFIG['host_os'] =~ /linux/ then
          system("xdg-open '#{link}'", [:out, :err]=>'/dev/null')
      end
      status("Loading #{link}...", :success)
    end

    def paginate
    end

    def reverse_paginate
    end

    private 

    def setup_curses
      noecho # don't show typed keys
      init_screen
      cbreak # make typed keys immediately acessible
      curs_set(0)
      stdscr.keypad(true) # enable arrow keys

      if can_change_color?
        start_color
        init_pair(0, COLOR_WHITE, COLOR_BLACK)   # ui:default
        init_pair(1, COLOR_BLACK, COLOR_CYAN)    # ui:header
        init_pair(2, COLOR_BLACK, COLOR_CYAN)    # ui:footer
        init_pair(3, COLOR_MAGENTA, COLOR_BLACK) # ui:selected

        init_pair(4, COLOR_WHITE, COLOR_BLACK)   # torrent:normal
        init_pair(5, COLOR_GREEN, COLOR_BLACK)   # torrent:trusted
        init_pair(6, COLOR_BLUE, COLOR_BLACK)    # torrent:aplus
        init_pair(7, COLOR_RED, COLOR_BLACK)    # torrent:remake

        init_pair(8, COLOR_BLACK, COLOR_GREEN)  # type:success
        init_pair(9, COLOR_BLACK, COLOR_RED)    # type:failure
      end
    end

    def torrent_status(torrent)
      case torrent.status
      when 'Trusted' then 5
      when 'A+'      then 6
      when 'Remake'  then 7
      else 4
      end
    end

    def truncate(text, width)
      if text.length > width
        truncated = "#{text[0..width-4]}..."
      else
        text
      end
    end

  end # UI
end # Nyaa
