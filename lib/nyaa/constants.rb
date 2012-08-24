module Nyaa

    BASE_URL = 'http://www.nyaa.eu/?page=torrents'
    PSIZE = 100

    CATS = {
      'anime_all'         => '1_0',
      'anime_raw'         => '1_11',
      'anime_english'     => '1_37',
      'anime_nonenglish'  => '1_38',
      'anime_music_video' => '1_32',
      'books_all'         => '2_0',
      'books_raw'         => '2_13',
      'books_english'     => '2_12',
      'books_nonenglish'  => '2_39',
      'audio_all'         => '3_0',
      'audio_lossless'    => '3_14',
      'audio_lossy'       => '3_15',
      'pictures_all'      => '4_0',
      'pictures_photos'   => '4_17',
      'pictures_graphics' => '4_18',
      'live_all'          => '5_0',
      'live_raw'          => '5_20',
      'live_english'      => '5_19',
      'live_nonenglish'   => '5_21',
      'live_promo'        => '5_22',
      'software_all'      => '6_0',
      'software_apps'     => '6_23',
      'software_games'    => '6_24',
    }

    FILS = {
      'show_all'       => '0',
      'filter_remakes' => '1',
      'trusted_only'   => '2',
      'aplus_only'     => '3',
    }

end
