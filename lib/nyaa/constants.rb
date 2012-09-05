# -*- encoding : utf-8 -*-
module Nyaa

    BASE_URL = 'http://www.nyaa.eu/?page=torrents'
    PSIZE = 100

    CATS = {
      :anime_all         => {
        :id    => '1_0',
        :title => 'Anime'
      },
      :anime_raw         => {
        :id    => '1_11',
        :title => 'Anime >> Raw Anime'
      },
      :anime_english     => {
        :id    => '1_37',
        :title => 'Anime >> English-translated Anime'
      },
      :anime_nonenglish  => {
        :id    => '1_38',
        :title => 'Anime >> Non-English-translated Anime'
      },
      :anime_music_video => {
        :id    => '1_32',
        :title => 'Anime >> Anime Music Video'
      },
      :books_all         => {
        :id    => '2_0',
        :title => 'Books'
      },
      :books_raw         => {
        :id    => '2_13',
        :title => 'Books >> Raw Books'
      },
      :books_english     => {
        :id    => '2_12',
        :title => 'Books >> English-scanlated Books'
      },
      :books_nonenglish  => {
        :id    => '2_39',
        :title => 'Books >> Non-English-scanlated Books'
      },
      :audio_all         => {
        :id    => '3_0',
        :title => 'Audio'
      },
      :audio_lossless    => {
        :id    => '3_14',
        :title => 'Audio >> Lossless Audio'
      },
      :audio_lossy       => {
        :id    => '3_15',
        :title => 'Audio >> Lossy Audio'
      },
      :pictures_all      => {
        :id    => '4_0',
        :title => 'Pictures'
      },
      :pictures_photos   => {
        :id    => '4_17',
        :title => 'Pictures >> Photos'
      },
      :pictures_graphics => {
        :id    => '4_18',
        :title => 'Pictures >> Graphics'
      },
      :live_all          => {
        :id    => '5_0',
        :title => 'Live Action'
      },
      :live_raw          => {
        :id    => '5_20',
        :title => 'Live Action >> Raw Live Action'
      },
      :live_english      => {
        :id    => '5_19',
        :title => 'Live Action >> English-translated Live Action'
      },
      :live_nonenglish   => {
        :id    => '5_21',
        :title => 'Live Action >> Non-English-translated Live Action'
      },
      :live_promo        => {
        :id    => '5_22',
        :title => 'Live Action >> Live Action Promotional Video'
      },
      :software_all      => {
        :id    => '6_0',
        :title => 'Software'
      },
      :software_apps     => {
        :id    => '6_23',
        :title => 'Software >> Applications'
      },
      :software_games    => {
        :id    => '6_24',
        :title => 'Software >> Games'
      },
    }

    FILS = {
      :show_all       => {
        :id    => '0',
        :title => 'Show all'
      },
      :filter_remakes => {
        :id    => '1',
        :title => 'Filter Remakes'
      },
      :trusted_only   => {
        :id    => '2',
        :title => 'Trusted only'
      },
      :aplus_only     => {
        :id    => '3',
        :title => 'A+ only'
      },
    }
end
