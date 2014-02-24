# -*- encoding : utf-8 -*-
include Curses

module Nyaa
  class UI
    attr_accessor :menusize, :page

    DOC = "#{Nyaa::Utils.gem_libdir}/HELP"

    def initialize (config, search)
      @config = config
      @status = { :text => 'Ready.', :type => :default }
      setup_curses

      # columns
      @info_columns = %w[ Size SE LE ]
      @info_column_width = 10
      @name_column_width = 0

      # commands
      @commands = {
        '?' => 'help',
        'g' => 'get',
		's' => 'start',
        'i' => 'info',
        'n' => 'next',
        'p' => 'prev',
        'q' => 'quit',
      }

      @search = search
      @torrents = @search.more.results
      @num_torrents = @torrents.size
	  @loading = @torrents.size % 100 == 0 ? true : false;
	  harvester # start bg harvester
      
      @menusize = lines - 4 # lines - header + footer + status
      @page = 1
      @num_pages = (@search.count/@menusize.to_f).ceil
      @offset = 0
      # TODO: on hold state: prevent paging forward when waiting on results
    end

    def header
      # pad info columns to column width
      @info_columns = @info_columns.map do |column|
        sprintf("%#{@info_column_width}s", column)
      end
      # key column width is whatever is leftover
      @name_column_width = cols - (@info_columns.length * @info_column_width)

      # header bar
      cat = CATS[@config[:category].to_sym][:title]
      header_text = sprintf " %-#{@name_column_width-1}s%s", "Nyaa - #{cat}", @info_columns.join
      attrset(color_pair(1))
      setpos(0,0)
      addstr(sprintf "%-#{cols}s", header_text)
    end

    def footer
      footer_text = @commands.map { |k,v| "#{k}: #{v}" }.join('  ')
      attrset(color_pair(2))
      setpos(lines - 1, 0)
      addstr(sprintf " %-#{cols}s", footer_text)

      search_summary = sprintf " %-14s %-14s %-14s",
        "view: [#{@offset+1}-#{@offset+@menusize}]/#{@search.count}",
        "recv: #{@num_torrents}/#{@loading ? "unk" : @search.count}",
        "page: #{@page}/#{@loading ? "unk" : @num_pages}"
      attrset(color_pair(2))
      setpos(lines - 2, 0)
      addstr(sprintf "%-#{cols}s", search_summary)
    end

    def status(text = nil, type = nil)
      @status[:text] = text if text
      @status[:type] = type

      case @status[:type]
      when :success then profile = 8
      when :failure then profile = 9
      else profile = 1
      end

      status_text = sprintf " Status: %-s", @status[:text]
      attrset(color_pair(profile))
      setpos(lines-3,0)
      addstr(sprintf "%-#{cols}s", status_text)
      refresh
    end

    def menu(highlight)
      xpos = 1
      attrset(color_pair(0))
      setpos(xpos, 0)

      (0..@menusize-1).each do |i|

        if i < @search.count - @offset
            line_text = sprintf("% -#{@name_column_width}s %9s %9s %9s",
              truncate("#{@torrents[@offset + i].name}", @name_column_width),
              @torrents[@offset + i].filesize,
              @torrents[@offset + i].seeders,
              @torrents[@offset + i].leechers)

            attrset(color_pair(torrent_status(@torrents[@offset + i])))
            setpos(xpos, 0)
            # highlight the present choice
            if highlight == i + 1
              attron(A_STANDOUT)
              addstr(line_text)
              attroff(A_STANDOUT)
            else
              addstr(line_text)
            end
            xpos += 1
        else
          # blank lines if there's < @menusize of results
          line_text = " "*cols
          addstr(line_text)
          xpos += 1
		end 
      end

	  status("Fetching more results, try again.", :failure) if @loading && @torrents[@offset + 1].nil?;
    end

    def help
      system("less #{DOC}")
      clear
    end

    def move(cursor, increment)
      if increment < 0 # negative, retreat!
        if cursor == 1
          if @offset == 0
            cursor = 1
          else
            prev_page
            cursor = menusize
          end
        else
          cursor = cursor + increment
        end
      else # non-negative, advance!
        if cursor == menusize
          next_page
          cursor = 1
        else
          cursor = cursor + increment
        end
      end
    end

    def get(choice)
      torrent = @torrents[@offset + choice - 1]
      download = Downloader.new(torrent.link, @config[:output])
      path = download.save

      unless download.failed?
        status("Downloaded successful: #{torrent.tid}", :success)
      else
        status("Download failed (3 attempts): #{torrent.tid}", :failure)
	return nil;
      end

      return path;
    end

	def start(choice)
		path = self.get(choice);
		self.open(path) if path != nil;
	end

    def open(choice)
      
      link = choice.class == Fixnum ? @torrents[@offset + choice - 1].info.to_s : choice;

      if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/ then
          system("start #{link}")
      elsif RbConfig::CONFIG['host_os'] =~ /darwin/ then
          system("open '#{link}'", [:out, :err]=>'/dev/null')
      elsif RbConfig::CONFIG['host_os'] =~ /linux/ then
          system("xdg-open '#{link}'", [:out, :err]=>'/dev/null')
      end

      status("Opened '#{link}'", :success)
    end

    def next_page
      status("Ready.")
      unless @page + 1 > @num_pages && @loading == false
        @page += 1
      end

      @offset = (page - 1) * @menusize;

    end

    def prev_page
      unless @page - 1 < 1
        @page += -1
      end

      @offset = (@page - 1) * @menusize;

	end

    def resize_handler(cursor)
      @menusize = lines - 4
      menu(cursor)
      refresh
    end

    def harvester
      Thread.new do
	    last = @torrents.size;
        
		loop do
          @torrents = @search.more.results
          @num_torrents = @torrents.size

		  if last == @torrents.size then
			@loading = false;
			@num_pages = (@torrents.size / @menusize.to_f).ceil;
			@page = @page > @num_pages ? @num_pages : @page;
			@offset = (@page - 1) * @menusize;
			break;
		  end

          last = @torrents.size;
		  sleep(2);
		end

        Thread.kill
      end
    end

    private 

    def setup_curses
      noecho # don't show typed keys
      init_screen # start curses mode
      cbreak # disable line buffering
      curs_set(0) # make cursor invisible
      stdscr.keypad(true) # enable arrow keys

      # set keyboard input timeout - sneaky way to manage refresh rate
      timeout = 500 # milliseconds

      if can_change_color?
        start_color
        init_pair(0, COLOR_WHITE, COLOR_BLACK)   # ui:default
        init_pair(1, COLOR_BLACK, COLOR_CYAN)    # ui:header
        init_pair(2, COLOR_BLACK, COLOR_YELLOW)  # ui:footer
        init_pair(3, COLOR_MAGENTA, COLOR_BLACK) # ui:selected

        init_pair(4, COLOR_WHITE, COLOR_BLACK) # torrent:normal
        init_pair(5, COLOR_GREEN, COLOR_BLACK) # torrent:trusted
        init_pair(6, COLOR_BLUE, COLOR_BLACK)  # torrent:aplus
        init_pair(7, COLOR_RED, COLOR_BLACK)   # torrent:remake

        init_pair(8, COLOR_BLACK, COLOR_GREEN) # type:success
        init_pair(9, COLOR_BLACK, COLOR_RED)   # type:failure
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
