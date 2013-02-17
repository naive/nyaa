# Nyaa

Nyaa is a CLI to Nyaa.eu. You can browse, search, and download. Nifty.

## Features

* Ncurses interface
* Search by category, filter, page, and query
* Browsing with pagination
* Download it or open a browser window from the interface
* Nyaa status aware: (aplus, trusted, remake, etc.)
* Batch mode for scripts (first page only atm)
* Supports unicode characters (requires `libncursesw5-dev` and `ruby1.9`)

## Installation

Stable release:

    gem install nyaa

Development release:

    git clone git://github.com/mistofvongola/nyaa.git

## Browser Usage

To start browsing immediately, simply run `nyaa`. The default category is english anime.

Nyaa supports all the aspects of search of the main site. You can search by category and/or filters. Nyaa also shows a summary of seeders, leechers, total filesize, and number of downloads. To download an item, highlight it, and type `g`.

    nyaa -c anime_english -f trusted_only 'sword art online'

For a list of categories and filters, see `nyaa -h`.

## The old interface

The old nyaa interface is deprecated, but is still included. You can use the old interface using the `--classic` option.

![](https://github.com/mistofvongola/nyaa/raw/master/screenshots/screenshot_1.png)

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
