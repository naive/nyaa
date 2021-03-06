# Nyaa

Nyaa is a CLI to Nyaa.eu. You can browse, search, and download. Nifty.

## Features

* Ncurses interface
* Search by category, filter, page, and query
* Sort by various attributes (date, seeds, downloads, etc.)
* Browsing with pagination
* Download it or open a browser window from the interface
* Nyaa status aware: (a+, trusted, remake, etc.)
* Batch mode for scripts (first page only atm)
* Supports unicode characters (requires `libncursesw5-dev` and `ruby1.9` or
  greater)
* Tested on Ruby 1.8.7-p371, 1.9.3-p327, 2.0.0-p0

## Installation

Stable release:

    gem install nyaa

Development release:

    git clone git://github.com/mistofvongola/nyaa.git

## Browser Usage

To browse, simply run `nyaa`. The default category is english anime.

![](http://i.imgur.com/Tzi6zo1.png)

Nyaa supports all the aspects of search of the main site. You can search by category and/or filters. To download an item, highlight it, and type `g`. To open the description page in a browser, type `i`. A sample query:

    nyaa -f trusted_only psycho pass

![](http://i.imgur.com/mhBQHS1.png)

For a list of categories and filters, see `nyaa -h`.

![](http://i.imgur.com/In44LcD.png)

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT License. See LICENSE file for details.

## Authors

David Palma

## Contributors

* [Yengas](https://github.com/Yengas)

