require 'cgi'

module MediaHelper
  def detect_platform(url)
    return 'unknown' if url.blank?
    
    url = url.strip.downcase
    
    case url
    when /music\.youtube\.com/
      'youtube_music'
    when /youtube\.com.*[?&]v=[\w-]+/, /youtu\.be\/[\w-]+/
      'youtube'
    when /vimeo\.com\/\d+/
      'vimeo'
    when /instagram\.com\/(p|reel)\/[\w-]+/
      'instagram'
    when /soundcloud\.com\/[\w-]+\/[\w-]+/
      'soundcloud'
    when /open\.spotify\.com\/(track|album|playlist)\/[\w]+/
      'spotify'
    when /tiktok\.com/
      'tiktok'
    when /\.(mp4|webm|ogg|mov|avi)$/i
      'video_file'
    when /\.(mp3|wav|ogg|m4a|flac)$/i
      'audio_file'
    else
      'unknown'
    end
  end


  def generate_embed_code(platform, url)
    case platform
    when 'youtube', 'youtube_music'
      video_id = extract_youtube_id(url)
      return "Invalid YouTube URL" unless video_id
      "<iframe id='youtube-player-#{video_id}' width='100%' height='315' src='https://www.youtube.com/embed/#{video_id}?enablejsapi=1&rel=0&modestbranding=1&origin=#{ENV['ORIGIN'] || 'http://localhost:3100'}' frameborder='0' allow='autoplay; encrypted-media' allowfullscreen></iframe>"
    when 'vimeo'
      video_id = extract_vimeo_id(url)
      return "Invalid Vimeo URL" unless video_id
      "<iframe src='https://player.vimeo.com/video/#{video_id}?autoplay=0' width='100%' height='360' frameborder='0' allow='autoplay; fullscreen' allowfullscreen></iframe>"
    when 'soundcloud'
      encoded_url = CGI.escape(url)
      "<iframe width='100%' height='166' scrolling='no' frameborder='no' src='https://w.soundcloud.com/player/?url=#{encoded_url}&color=%23ff5500&auto_play=false&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true'></iframe>"
    when 'spotify'
      track_id = extract_spotify_id(url)
      return "Invalid Spotify URL" unless track_id
      "<iframe src='https://open.spotify.com/embed/track/#{track_id}' width='100%' height='152' frameborder='0' allowtransparency='true' allow='encrypted-media'></iframe>"
    when 'tiktok'
      # TikTok embeds are tricky, let's use a simpler approach
      "<div class='alert alert-info text-center'><strong>TikTok Video</strong><br><small>#{url}</small><br><a href='#{url}' target='_blank' class='btn btn-sm btn-dark mt-2'>Open in TikTok</a></div>"
    when 'instagram'
      post_id = extract_instagram_id(url)
      return "Invalid Instagram URL" unless post_id
      "<blockquote class='instagram-media' data-instgrm-permalink='#{url}' data-instgrm-version='14' style='background:#FFF; border:0; border-radius:3px; box-shadow:0 0 1px 0 rgba(0,0,0,0.5),0 1px 10px 0 rgba(0,0,0,0.15); margin: 1px; max-width:540px; min-width:326px; padding:0; width:99.375%; width:-webkit-calc(100% - 2px); width:calc(100% - 2px);'></blockquote><script async src='//www.instagram.com/embed.js'></script>"
    when 'video_file'
      "<video width='100%' height='315' controls preload='metadata'><source src='#{url}' type='video/mp4'>Your browser does not support the video tag.</video>"
    when 'audio_file'
      "<audio controls preload='metadata' style='width: 100%;'><source src='#{url}' type='audio/mpeg'>Your browser does not support the audio tag.</audio>"
    else
      "<div class='alert alert-warning text-center'><strong>Unsupported Platform</strong><br><small>#{url}</small><br><a href='#{url}' target='_blank' class='btn btn-sm btn-primary mt-2'>Open Link</a></div>"
    end
  end

  def get_thumbnail_url(platform, url)
    case platform
    when 'youtube', 'youtube_music'
      video_id = extract_youtube_id(url)
      video_id ? "https://img.youtube.com/vi/#{video_id}/mqdefault.jpg" : generate_placeholder_svg(platform)
    when 'vimeo'
      generate_placeholder_svg(platform)
    when 'instagram'
      generate_placeholder_svg(platform)
    when 'tiktok'
      generate_placeholder_svg(platform)
    when 'spotify'
      generate_placeholder_svg(platform)
    when 'soundcloud'
      generate_placeholder_svg(platform)
    else
      generate_placeholder_svg('media')
    end
  end

  def generate_placeholder_svg(platform)
    colors = {
      'youtube' => { bg: '#ff0000', text: '#ffffff', symbol: '▶', name: 'YouTube' },
      'youtube_music' => { bg: '#ff0000', text: '#ffffff', symbol: '♪', name: 'YouTube Music' },
      'vimeo' => { bg: '#1ab7ea', text: '#ffffff', symbol: '▶', name: 'Vimeo' },
      'instagram' => { bg: '#e4405f', text: '#ffffff', symbol: '○', name: 'Instagram' },
      'tiktok' => { bg: '#000000', text: '#ffffff', symbol: '♪', name: 'TikTok' },
      'spotify' => { bg: '#1db954', text: '#ffffff', symbol: '♪', name: 'Spotify' },
      'soundcloud' => { bg: '#ff5500', text: '#ffffff', symbol: '♪', name: 'SoundCloud' },
      'media' => { bg: '#6c757d', text: '#ffffff', symbol: '♪', name: 'Media' }
    }
    
    config = colors[platform] || colors['media']
    
    svg_content = <<~SVG
      <svg width="320" height="180" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#{config[:bg]}"/>
        <text x="50%" y="40%" font-family="Arial, sans-serif" font-size="32" 
              text-anchor="middle" fill="#{config[:text]}">#{config[:symbol]}</text>
        <text x="50%" y="65%" font-family="Arial, sans-serif" font-size="16" 
              text-anchor="middle" fill="#{config[:text]}">#{config[:name]}</text>
      </svg>
    SVG
    
    # Use URL encoding instead of base64 to avoid emoji encoding issues
    "data:image/svg+xml;charset=utf-8,#{CGI.escape(svg_content)}"
  end

  def extract_title_from_url(platform, url)
    case platform
    when 'youtube', 'youtube_music'
      # Try to extract from URL parameters or return generic title
      if url.include?('&t=') || url.include?('?t=')
        'YouTube Video'
      else
        'YouTube Video'
      end
    when 'vimeo'
      'Vimeo Video'
    when 'instagram'
      'Instagram Post'
    when 'tiktok'
      'TikTok Video'
    when 'spotify'
      'Spotify Track'
    when 'soundcloud'
      'SoundCloud Track'
    when 'video_file'
      File.basename(url, '.*').humanize
    when 'audio_file'
      File.basename(url, '.*').humanize
    else
      'Unknown Media'
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
