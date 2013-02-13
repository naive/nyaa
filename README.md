# Nyaa

Nyaa is a CLI to Nyaa.eu. You can browse, search, and download. Nifty.

## Features

* Search by category, filter, page, and query
* Browsing with pagination
* Caches pages for performance (experimental)
* Nyaa status aware: (aplus, trusted, remake, etc.)
* Batch mode for scripts

## Installation

Stable release:

    gem install nyaa

Development release:

    git clone git://github.com/mistofvongola/nyaa.git

## Browser Usage

To start browsing immediately, simply run `nyaa`. The default category is english anime.

![](https://github.com/mistofvongola/nyaa/raw/master/screenshots/screenshot_1.png)

Nyaa supports all the aspects of search of the main site. You can search by category and/or filters. Nyaa also shows a summary of seeders, leechers, total filesize, and number of downloads. To download an item, simply enter the number of the result.

    nyaa -c anime_english -f trusted_only 'guilty crown'

![](https://github.com/mistofvongola/nyaa/raw/master/screenshots/screenshot_2.png)

For a list of categories and filters, see `nyaa -h`.

![](https://github.com/mistofvongola/nyaa/raw/master/screenshots/screenshot_3.png)

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
