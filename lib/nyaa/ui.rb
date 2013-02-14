include Curses

module Nyaa
  class UI
    def initialize (config)
      @config = config

      # Normally, the tty driver buffers typed characters until a newline.
      # cbreak makes characters typed immediately available to the program.
      init_screen
      cbreak
      curs_set(0)

      # color pairs
      if can_change_color?
        start_color # init color attributes
        # section colors
        init_pair(0, COLOR_WHITE, COLOR_BLACK)
        init_pair(1, COLOR_BLACK, COLOR_CYAN)
        init_pair(2, COLOR_WHITE, COLOR_BLACK)
        # status colors
        init_pair(3, COLOR_WHITE, COLOR_GREEN)
        init_pair(4, COLOR_WHITE, COLOR_BLUE)
        init_pair(5, COLOR_WHITE, COLOR_RED)
      end

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

      # set attributes
      cat = CATS[@config[:category].to_sym][:title]
      attrset(color_pair(1))
      setpos(0,0)
      addstr(sprintf " %-#{@name_column_width - 1}s%s", "Nyaa - #{cat}", @info_columns.join)
    end

    def footer
      # set attributes
      footer_text = @commands.map { |k,v| "#{k}: #{v}" }.join('  ')
      attrset(color_pair(1))
      setpos(lines - 1, 0)
      addstr(sprintf " %-#{cols}s", footer_text)
    end

    def render
      #nyaa = Nyaa::Search.new(@config[:query], @config[:category], @config[:filter])
      #results = nyaa.more.get_results
      #results.each do |r|
      #  puts "#{r.name}"
      #end

      attrset(color_pair(2))
      setpos(1, 0)
      addstr("Fake data, lalala")
    end

    def read
      getch
    end

    def close
      nocbreak
      close_screen
    end

  end # UI
end # Nyaa
