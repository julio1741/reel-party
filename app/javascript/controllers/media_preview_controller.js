import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["url", "preview"]

  connect() {
    console.log("Media preview controller connected")
  }

  showPreview() {
    const url = this.urlTarget.value.trim()
    if (!url) {
      this.clearPreview()
      return
    }

    const platform = this.detectPlatform(url)
    const thumbnail = this.getThumbnailUrl(platform, url)
    const title = this.getTitle(platform, url)

    this.renderPreview(platform, title, thumbnail, url)
  }

  detectPlatform(url) {
    if (/music\.youtube\.com/.test(url)) return 'youtube_music'
    if (/youtube\.com|youtu\.be/.test(url)) return 'youtube'
    if (/vimeo\.com/.test(url)) return 'vimeo'
    if (/instagram\.com\/(p|reel)\//.test(url)) return 'instagram'
    if (/soundcloud\.com/.test(url)) return 'soundcloud'
    if (/spotify\.com/.test(url)) return 'spotify'
    if (/tiktok\.com/.test(url)) return 'tiktok'
    if (/\.(mp4|webm|ogg)$/.test(url)) return 'video_file'
    if (/\.(mp3|wav|ogg)$/.test(url)) return 'audio_file'
    return 'unknown'
  }

  getThumbnailUrl(platform, url) {
    switch(platform) {
      case 'youtube':
      case 'youtube_music':
        const videoId = this.extractYouTubeId(url)
        return videoId ? `https://img.youtube.com/vi/${videoId}/mqdefault.jpg` : this.generatePlaceholderSvg(platform)
      default:
        return this.generatePlaceholderSvg(platform)
    }
  }

  generatePlaceholderSvg(platform) {
    const colors = {
      'youtube': { bg: '#ff0000', text: '#ffffff', symbol: '▶', name: 'YouTube' },
      'youtube_music': { bg: '#ff0000', text: '#ffffff', symbol: '♪', name: 'YouTube Music' },
      'vimeo': { bg: '#1ab7ea', text: '#ffffff', symbol: '▶', name: 'Vimeo' },
      'instagram': { bg: '#e4405f', text: '#ffffff', symbol: '📷', name: 'Instagram' },
      'tiktok': { bg: '#000000', text: '#ffffff', symbol: '♪', name: 'TikTok' },
      'spotify': { bg: '#1db954', text: '#ffffff', symbol: '♪', name: 'Spotify' },
      'soundcloud': { bg: '#ff5500', text: '#ffffff', symbol: '♪', name: 'SoundCloud' },
      'media': { bg: '#6c757d', text: '#ffffff', symbol: '♪', name: 'Media' }
    }
    
    const config = colors[platform] || colors['media']
    
    const svgContent = `<svg width="320" height="180" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="${config.bg}"/>
        <text x="50%" y="40%" font-family="Arial, sans-serif" font-size="32" 
              text-anchor="middle" fill="${config.text}">${config.symbol}</text>
        <text x="50%" y="65%" font-family="Arial, sans-serif" font-size="16" 
              text-anchor="middle" fill="${config.text}">${config.name}</text>
      </svg>`
    
    // Use URL encoding instead of base64 to avoid emoji encoding issues
    return `data:image/svg+xml;charset=utf-8,${encodeURIComponent(svgContent)}`
  }

  getTitle(platform, url) {
    switch(platform) {
      case 'youtube':
      case 'youtube_music':
        return 'YouTube Video'
      case 'vimeo':
        return 'Vimeo Video'
      case 'instagram':
        return 'Instagram Post'
      case 'tiktok':
        return 'TikTok Video'
      case 'spotify':
        return 'Spotify Track'
      case 'soundcloud':
        return 'SoundCloud Track'
      case 'video_file':
        return this.getFilename(url)
      case 'audio_file':
        return this.getFilename(url)
      default:
        return 'Unknown Media'
    }
  }

  extractYouTubeId(url) {
    const match = url.match(/(?:youtube\.com.*(?:v=|\/embed\/)|youtu\.be\/)([\w-]+)/)
    return match ? match[1] : null
  }

  getFilename(url) {
    return url.split('/').pop().split('.')[0] || 'Media File'
  }

  renderPreview(platform, title, thumbnail, url) {
    if (!this.hasPreviewTarget) return

    const platformEmojis = {
      youtube: '▶️ YouTube',
      youtube_music: '🎵 YouTube Music',
      vimeo: '🎬 Vimeo',
      instagram: '📸 Instagram',
      tiktok: '🎵 TikTok',
      spotify: '🎧 Spotify',
      soundcloud: '🔊 SoundCloud',
      video_file: '🎥 Video File',
      audio_file: '🎵 Audio File',
      unknown: '❓ Unknown'
    }

    this.previewTarget.innerHTML = `
      <div class="card mt-3">
        <div class="card-body">
          <h6 class="card-title">Preview</h6>
          <div class="d-flex align-items-start">
            <img src="${thumbnail}" alt="Thumbnail" class="me-3 rounded" style="width: 80px; height: 60px; object-fit: cover;">
            <div>
              <div><strong>${title}</strong></div>
              <small class="text-muted">${platformEmojis[platform] || platform}</small>
              <br>
              <small class="text-muted" style="word-break: break-all;">${this.truncate(url, 60)}</small>
            </div>
          </div>
        </div>
      </div>
    `
  }

  clearPreview() {
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ''
    }
  }

  truncate(str, length) {
    return str.length > length ? str.substring(0, length) + '...' : str
  }
}