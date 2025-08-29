import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["player"]
  static values = { sessionId: Number }

  connect() {
    console.log("Autoplay controller connected - VERSION 2.2", {
      sessionId: this.sessionIdValue
    })
    // Small delay to ensure DOM is fully loaded
    setTimeout(() => {
      this.setupAutoplay()
      this.startCurrentMedia()
    }, 500)
  }

  setupAutoplay() {
    console.log("Setting up autoplay...")
    
    // Clean up any existing autoplay setups
    this.cleanupAutoplay()
    
    // Set up YouTube autoplay
    this.setupYouTubeAutoplay()
    
    // Set up HTML5 video/audio autoplay  
    this.setupHTML5Autoplay()
    
    // Periodic check for completion (fallback)
    this.startPeriodicCheck()
  }

  cleanupAutoplay() {
    // Clear any existing intervals
    if (this.checkInterval) {
      clearInterval(this.checkInterval)
      this.checkInterval = null
    }
    
    if (this.soundcloudCheckInterval) {
      clearInterval(this.soundcloudCheckInterval)
      this.soundcloudCheckInterval = null
    }
    
    // Clean up YouTube player if it exists
    if (this.ytPlayer) {
      try {
        this.ytPlayer.destroy()
        this.ytPlayer = null
      } catch (error) {
        console.log("Error destroying YouTube player:", error)
      }
    }
    
    // Reset debounce flag
    this.playingNext = false
  }

  setupYouTubeAutoplay() {
    // Create a unique callback for this instance
    const callbackName = `onYouTubePlayerStateChange_${Math.random().toString(36).substring(2, 11)}`
    
    window[callbackName] = (event) => {
      console.log("YouTube player state changed:", event.data)
      // YT.PlayerState.ENDED = 0
      if (event.data === 0) {
        console.log("YouTube video ended, playing next...")
        setTimeout(() => this.playNext(), 1000) // Small delay to ensure state is processed
      }
    }

    // Load YouTube API if needed
    this.loadYouTubeAPI(() => {
      this.initYouTubePlayer(callbackName)
    })
  }

  loadYouTubeAPI(callback) {
    if (window.YT && window.YT.Player) {
      callback()
      return
    }

    if (document.querySelector('script[src*="youtube.com/iframe_api"]')) {
      // API is loading, wait for it
      const checkInterval = setInterval(() => {
        if (window.YT && window.YT.Player) {
          clearInterval(checkInterval)
          callback()
        }
      }, 100)
      return
    }

    // Load the API
    const tag = document.createElement('script')
    tag.src = "https://www.youtube.com/iframe_api"
    document.head.appendChild(tag)

    window.onYouTubeIframeAPIReady = () => {
      console.log("YouTube API loaded")
      callback()
    }
  }

  initYouTubePlayer(callbackName) {
    const iframe = this.element.querySelector('iframe[src*="youtube.com"]')
    if (!iframe || !iframe.id) {
      console.log("No YouTube iframe found")
      return
    }

    try {
      console.log("Initializing YouTube player:", iframe.id)
      this.ytPlayer = new window.YT.Player(iframe.id, {
        events: {
          'onStateChange': window[callbackName],
          'onReady': () => {
            console.log("YouTube player ready")
          },
          'onError': (event) => {
            console.log("YouTube player error:", event.data)
          }
        }
      })
    } catch (error) {
      console.log("Error initializing YouTube player:", error)
    }
  }

  setupHTML5Autoplay() {
    // Delay to allow DOM to update
    setTimeout(() => {
      const videos = this.element.querySelectorAll('video')
      const audios = this.element.querySelectorAll('audio')
      
      // Convert NodeLists to arrays and combine
      const allMediaElements = Array.from(videos).concat(Array.from(audios))
      
      allMediaElements.forEach(media => {
        console.log("Setting up HTML5 media autoplay for:", media.src)
        
        media.addEventListener('ended', () => {
          console.log("HTML5 media ended, playing next...")
          this.playNext()
        })

        // Also listen for error events
        media.addEventListener('error', (e) => {
          console.log("HTML5 media error:", e)
        })
      })

      // Setup SoundCloud autoplay detection
      this.setupSoundCloudAutoplay()
    }, 500)
  }

  setupSoundCloudAutoplay() {
    const soundcloudIframes = this.element.querySelectorAll('iframe[src*="soundcloud.com"]')
    soundcloudIframes.forEach(iframe => {
      console.log("Setting up SoundCloud autoplay detection")
      // SoundCloud doesn't have a reliable end event, so use periodic check
      this.soundcloudCheckInterval = setInterval(() => {
        this.checkSoundCloudStatus(iframe)
      }, 5000)
    })
  }

  checkSoundCloudStatus(iframe) {
    // This is a basic fallback - SoundCloud's API is limited in embeds
    // For now, we'll rely on the periodic check in the main function
    console.log("Checking SoundCloud status (fallback method)")
  }

  startPeriodicCheck() {
    // Check every 3 seconds as fallback
    this.checkInterval = setInterval(() => {
      this.checkForCompletion()
    }, 3000)
  }

  checkForCompletion() {
    // Check HTML5 media elements
    const videos = this.element.querySelectorAll('video')
    const audios = this.element.querySelectorAll('audio')
    
    const allMedia = Array.from(videos).concat(Array.from(audios))
    
    allMedia.forEach(media => {
      if (media.ended && !media.dataset.processedEnd) {
        console.log("Detected ended HTML5 media via polling")
        media.dataset.processedEnd = 'true'
        this.playNext()
      }
    })
  }

  playNext() {
    // Debounce to prevent multiple calls
    if (this.playingNext) return
    this.playingNext = true

    console.log("Auto-playing next song...")
    
    // Find the Next button - button_to creates a submit button, not an input
    const buttons = document.querySelectorAll('button[type="submit"]')
    let nextButton = Array.from(buttons).find(btn => btn.textContent.includes('Next'))
    
    // Also try looking for the form containing Next
    if (!nextButton) {
      const nextForm = document.querySelector('form[action*="play_next"]')
      if (nextForm) {
        nextButton = nextForm.querySelector('button[type="submit"]')
      }
    }
    
    if (nextButton) {
      console.log("Found Next button, clicking it...")
      nextButton.click()
      
      // Reset debounce
      setTimeout(() => {
        this.playingNext = false
      }, 3000)
    } else {
      console.log("No Next button found, trying alternative method")
      this.playingNext = false
    }
  }

  playNextViaSession() {
    const url = `/sessions/${this.sessionIdValue}/play_next`
    console.log("Fallback: Fetching session URL:", url)

    fetch(url, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
    })
    .then(response => {
      console.log('Fallback Response status:', response.status)
      console.log('Fallback Response URL:', response.url)
      
      if (response.ok) {
        return response.json()
      }
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    })
    .then(data => {
      console.log('Fallback Auto-advanced to next song:', data)
      if (data && data.success) {
        setTimeout(() => {
          this.setupAutoplay()
        }, 2000)
      } else {
        console.log('Fallback: No more songs in queue or failed response')
      }
    })
    .catch(error => {
      console.error('Fallback Error auto-advancing:', error)
      console.error('Session ID:', this.sessionIdValue)
    })
    .finally(() => {
      setTimeout(() => {
        this.playingNext = false
      }, 5000)
    })
  }

  startCurrentMedia() {
    console.log("Attempting to start current media...")
    
    // Try to start YouTube video
    this.startYouTubeVideo()
    
    // Try to start HTML5 media
    this.startHTML5Media()
  }

  startYouTubeVideo() {
    const iframe = this.element.querySelector('iframe[src*="youtube.com"]')
    if (!iframe || !iframe.id) {
      console.log("No YouTube iframe found")
      return
    }

    // Wait for YouTube API to be available
    if (window.YT && window.YT.Player) {
      try {
        // Try to get existing player first
        if (iframe.contentWindow && iframe.contentWindow.postMessage) {
          console.log("Attempting to play YouTube video via postMessage")
          const playCommand = {
            event: 'command',
            func: 'playVideo',
            args: []
          }
          iframe.contentWindow.postMessage(JSON.stringify(playCommand), 'https://www.youtube.com')
        }
      } catch (error) {
        console.log("Error starting YouTube video:", error)
      }
    }
  }

  startHTML5Media() {
    const videos = this.element.querySelectorAll('video')
    const audios = this.element.querySelectorAll('audio')
    
    const allMedia = Array.from(videos).concat(Array.from(audios))
    
    allMedia.forEach(media => {
      console.log("Attempting to play HTML5 media:", media.src)
      
      // Try to play the media
      const playPromise = media.play()
      
      if (playPromise !== undefined) {
        playPromise
          .then(() => {
            console.log("HTML5 media started playing successfully")
          })
          .catch(error => {
            console.log("HTML5 media autoplay prevented by browser:", error)
            // Show a play button or instruction to user
            this.showPlayInstruction(media)
          })
      }
    })
  }

  showPlayInstruction(media) {
    // Create a play button overlay
    const overlay = document.createElement('div')
    overlay.innerHTML = `
      <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); 
                  background: rgba(0,0,0,0.8); color: white; padding: 20px; border-radius: 10px; 
                  text-align: center; z-index: 1000;">
        <h5>▶️ Click to Play</h5>
        <p>Browser requires user interaction to start media</p>
        <button class="btn btn-primary btn-lg" onclick="this.parentElement.parentElement.remove(); this.closest('.autoplay-container').querySelector('video, audio').play()">
          Play Media
        </button>
      </div>
    `
    
    // Wrap media in a container if not already
    if (!media.parentElement.classList.contains('autoplay-container')) {
      const container = document.createElement('div')
      container.classList.add('autoplay-container')
      container.style.position = 'relative'
      media.parentElement.insertBefore(container, media)
      container.appendChild(media)
    }
    
    media.parentElement.appendChild(overlay)
  }

  disconnect() {
    console.log("Autoplay controller disconnecting")
    this.cleanupAutoplay()
  }
}