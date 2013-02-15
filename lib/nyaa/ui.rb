include Curses

module Nyaa
  class UI
    def initialize (config)
      @config = config
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
    end

    def header
      # pad info columns to column width
      @info_columns = @info_columns.map do |column|
        sprintf("%#{@info_column_width}s", column)
      end
      # key column width is whatever is leftover
      @name_column_width = cols - (@info_columns.length * @info_column_width)

      cat = CATS[@config[:category].to_sym][:title]
      attrset(color_pair(1))
      setpos(0,0)
      addstr(sprintf " %-#{@name_column_width-1}s%s", "Nyaa - #{cat}", @info_columns.join)
    end

    def footer
      footer_text = @commands.map { |k,v| "#{k}: #{v}" }.join('  ')
      attrset(color_pair(2))
      setpos(lines - 1, 0)
      addstr(sprintf " %-#{cols}s", footer_text)
    end

    def content
      rows = lines - 2 # lines - header + footer
      xpos = 1
      attrset(color_pair(0))
      setpos(xpos, 0)

      nyaa = Nyaa::Search.new(@config[:query], @config[:category], @config[:filter])
      @results = nyaa.more.get_results
      @results.each do |r|
        line = sprintf "% -#{@name_column_width}s %9s %9.d %9.d", r.name, r.filesize, r.seeders, r.leechers
        attrset(color_pair(torrent_status(r)))
        setpos(xpos, 0)
        addstr(line)
        xpos += 1
      end
    end

    def move(line, column)
      attrset(color_pair(5)) 
      setpos(line, column)
    end

    def torrent_status(torrent)
      case torrent.status
      when 'A+'      then 8
      when 'Trusted' then 6
      when 'Remake'  then 10
      else 4
      end
    end

    def cmd_help

    end

    def cmd_get
    end

    def cmd_info(torrent)
      link = torrent.info
      if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ then
          system("start #{link}")
      elsif RbConfig::CONFIG['host_os'] =~ /darwin/ then
          system("open #{link}")
      elsif RbConfig::CONFIG['host_os'] =~ /linux/ then
          system("xdg-open #{link}")
      end
    end

    def cmd_next
    end

    def cmd_prev
    end

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
        init_pair(4, COLOR_WHITE, COLOR_BLACK)   # status:normal
        init_pair(5, COLOR_BLACK, COLOR_WHITE)   # status:normal hover
        init_pair(6, COLOR_GREEN, COLOR_BLACK)   # status:trusted
        init_pair(7, COLOR_BLACK, COLOR_GREEN)   # status:trusted hover
        init_pair(8, COLOR_BLUE, COLOR_BLACK)    # status:aplus
        init_pair(9, COLOR_BLACK, COLOR_BLUE)    # status:aplus hover
        init_pair(10, COLOR_RED, COLOR_BLACK)    # status:remake
        init_pair(11, COLOR_BLACK, COLOR_RED)    # status:remake hover
      end
    end

  end # UI
end # Nyaa
