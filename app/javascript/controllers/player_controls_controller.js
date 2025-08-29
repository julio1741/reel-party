import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["player"]
  static values = { sessionId: Number, mediaId: Number }

  connect() {
    console.log("Player controls connected")
  }

  pause(event) {
    event.preventDefault()
    this.sendControlCommand('pause')
    this.pauseCurrentMedia()
  }

  resume(event) {
    event.preventDefault()
    this.sendControlCommand('resume')
    this.resumeCurrentMedia()
  }

  restart(event) {
    event.preventDefault()
    this.sendControlCommand('restart')
    this.restartCurrentMedia()
  }

  pauseCurrentMedia() {
    // Try YouTube first
    if (this.tryYouTubeControl('pause')) return
    
    // Try HTML5 video/audio
    this.tryHTML5Control('pause')
  }

  resumeCurrentMedia() {
    // Try YouTube first
    if (this.tryYouTubeControl('play')) return
    
    // Try HTML5 video/audio
    this.tryHTML5Control('play')
  }

  restartCurrentMedia() {
    // Try YouTube first
    if (this.tryYouTubeControl('restart')) return
    
    // Try HTML5 video/audio
    this.tryHTML5Control('restart')
  }

  tryYouTubeControl(action) {
    const iframe = this.playerTarget.querySelector('iframe[src*="youtube.com"]')
    if (!iframe || !window.YT || !window.YT.Player) return false

    try {
      const player = new window.YT.Player(iframe.id, {})
      
      switch(action) {
        case 'pause':
          player.pauseVideo()
          break
        case 'play':
          player.playVideo()
          break
        case 'restart':
          player.seekTo(0)
          player.playVideo()
          break
      }
      return true
    } catch (error) {
      console.log("YouTube control error:", error)
      return false
    }
  }

  tryHTML5Control(action) {
    const videos = this.playerTarget.querySelectorAll('video')
    const audios = this.playerTarget.querySelectorAll('audio')
    
    const mediaElements = [...videos, ...audios]
    
    mediaElements.forEach(media => {
      switch(action) {
        case 'pause':
          media.pause()
          break
        case 'play':
          media.play()
          break
        case 'restart':
          media.currentTime = 0
          media.play()
          break
      }
    })
  }

  sendControlCommand(action) {
    fetch(`/sessions/${this.sessionIdValue}/media/${this.mediaIdValue}/${action}`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data => {
      console.log(`${action} command sent:`, data)
    })
    .catch(error => {
      console.error(`Error sending ${action}:`, error)
    })
  }
}