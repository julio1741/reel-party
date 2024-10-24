module MediaHelper
  def detect_platform(url)
    case url
    when /music\.youtube\.com/
      'youtube_music'
    when /youtube\.com|youtu\.be/
      'youtube'
    when /vimeo\.com/
      'vimeo'
    when /instagram\.com\/(p|reel)\//
      'instagram'
    when /soundcloud\.com/
      'soundcloud'
    when /spotify\.com/
      'spotify'
    when /tiktok\.com/
      'tiktok'
    when /\.(mp4|webm|ogg)$/
      'video_file'
    when /\.(mp3|wav|ogg)$/
      'audio_file'
    else
      'unknown'
    end
  end


  def generate_embed_code(platform, url)
    case platform
    when 'youtube', 'youtube_music'
      video_id = extract_youtube_id(url)
      "<iframe width='560' height='315' src='https://www.youtube.com/embed/#{video_id}' frameborder='0' allow='autoplay; encrypted-media' allowfullscreen></iframe>"
    when 'vimeo'
      video_id = extract_vimeo_id(url)
      "<iframe src='https://player.vimeo.com/video/#{video_id}' width='640' height='360' frameborder='0' allow='autoplay; fullscreen' allowfullscreen></iframe>"
    when 'soundcloud'
      "<iframe width='100%' height='166' scrolling='no' frameborder='no' src='https://w.soundcloud.com/player/?url=#{url}'></iframe>"
    when 'spotify'
      "<iframe src='https://open.spotify.com/embed/track/#{extract_spotify_id(url)}' width='300' height='380' frameborder='0' allowtransparency='true' allow='encrypted-media'></iframe>"
    when 'tiktok'
      "<blockquote class='tiktok-embed' cite='#{url}' data-video-id='#{extract_tiktok_id(url)}' style='max-width: 605px;min-width: 325px;' > <section> </section> </blockquote>"
    when 'instagram'
      "<iframe src='https://instagram.com/p/#{extract_instagram_id(url)}/embed' width='400' height='480' frameborder='0' allowtransparency='true'></iframe>"
    when 'video_file'
      "<video width='560' height='315' controls><source src='#{url}' type='video/mp4'></video>"
    when 'audio_file'
      "<audio controls><source src='#{url}' type='audio/mpeg'></audio>"
    else
      'Unsupported platform'
    end
  end

  def extract_youtube_id(url)
    match = url.match(/(?:youtube\.com.*(?:v=|\/embed\/)|youtu\.be\/)([\w-]+)/)
    match ? match[1] : nil
  end


  def extract_vimeo_id(url)
    match = url.match(/vimeo\.com\/(\d+)/)
    match ? match[1] : nil
  end


  def extract_instagram_id(url)
    match = url.match(/instagram\.com\/(p|reel)\/([\w-]+)/)
    match ? match[2] : nil
  end

  def extract_spotify_id(url)
    match = url.match(/spotify\.com\/(track|album|playlist)\/([\w-]+)/)
    match ? match[2] : nil
  end


  def extract_tiktok_id(url)
    match = url.match(/tiktok\.com\/.*\/video\/(\d+)/)
    match ? match[1] : nil
  end

  def extract_tiktok_id(url)
    match = url.match(/tiktok\.com\/.*\/video\/(\d+)/)
    match ? match[1] : nil
  end

  # Audio/video Files
  def extract_file_name(url)
    File.basename(url)
  end

  def extract_media_id(url)
    case detect_platform(url)
    when 'youtube'
      extract_youtube_id(url)
    when 'vimeo'
      extract_vimeo_id(url)
    when 'instagram'
      extract_instagram_id(url)
    when 'soundcloud'
      extract_soundcloud_id(url)
    when 'spotify'
      extract_spotify_id(url)
    when 'tiktok'
      extract_tiktok_id(url)
    when 'video_file', 'audio_file'
      extract_file_name(url)
    else
      nil
    end
  end

end
