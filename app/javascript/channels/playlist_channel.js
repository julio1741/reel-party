import consumer from "./consumer"

document.addEventListener('DOMContentLoaded', function() {
  const playlistElement = document.getElementById('playlist')

  if (playlistElement) {
    const playlistId = playlistElement.dataset.playlistId

    consumer.subscriptions.create({ channel: "PlaylistChannel", playlist_id: playlistId }, {
      connected() {
        console.log("Connected to PlaylistChannel")
      },
      
      received(data) {
        console.log("Received:", data)
        
        if (data.action === 'remove') {
          this.handleRemove(data)
        } else if (data.action === 'add') {
          this.handleAdd(data)
        } else if (data.action === 'play_next') {
          this.handlePlayNext(data)
        } else if (data.action === 'pause') {
          this.handlePause(data)
        } else if (data.action === 'resume') {
          this.handleResume(data)
        } else if (data.action === 'restart') {
          this.handleRestart(data)
        }
      },

      handleRemove(data) {
        const mediumElement = document.getElementById(`medium-${data.id}`)
        if (mediumElement) {
          mediumElement.remove()
          this.updateQueueCount()
        }
      },

      handleAdd(data) {
        const mediaList = document.getElementById('playlist')
        if (mediaList) {
          if (data.status === 'playing') {
            // If this is the first item and it's playing, update the player
            this.updateMediaPlayer(data.embed_code)
          }
          
          // Add to appropriate section based on status
          if (data.status === 'queued') {
            mediaList.insertAdjacentHTML('beforeend', data.medium)
          }
        }
        
        this.updateQueueCount(data.queue_count)
      },

      handlePlayNext(data) {
        console.log("Handling play_next:", data)
        
        // Update the media player
        this.updateMediaPlayer(data.embed_code)
        
        // Move current playing item to completed section
        this.moveToCompleted(data.current_playing)
        
        // Update the current playing display
        this.updateCurrentPlaying(data.current_playing)
        
        // Update queue count
        this.updateQueueCount(data.queue_count)
        
        // Re-initialize autoplay for new media
        setTimeout(() => {
          this.reinitializeAutoplay()
        }, 1000)
      },

      updateMediaPlayer(embedCode) {
        const mediaPlayer = document.getElementById('media-player')
        if (mediaPlayer && embedCode) {
          mediaPlayer.innerHTML = embedCode
        }
      },

      updateCurrentPlaying(mediaId) {
        // Remove existing playing indicators
        document.querySelectorAll('.list-group-item-warning').forEach(el => {
          el.classList.remove('list-group-item-warning')
        })
        
        // Add playing indicator to current item
        const currentElement = document.getElementById(`medium-${mediaId}`)
        if (currentElement) {
          currentElement.classList.add('list-group-item-warning')
        }
      },

      updateQueueCount(count) {
        if (count !== undefined) {
          // Find the queue header by text content
          const headers = document.querySelectorAll('h4')
          const queueHeader = Array.from(headers).find(h => h.textContent.includes('Up Next'))
          if (queueHeader) {
            queueHeader.innerHTML = `⏱️ Up Next (${count} in queue)`
          }
        }
      },

      handlePause() {
        this.controlMedia('pause')
      },

      handleResume() {
        this.controlMedia('resume')
      },

      handleRestart() {
        this.controlMedia('restart')
      },

      controlMedia(action) {
        // Try YouTube first
        if (this.controlYouTube(action)) return
        
        // Try HTML5 video/audio
        this.controlHTML5(action)
      },

      controlYouTube(action) {
        const iframe = document.querySelector('iframe[src*="youtube.com"]')
        if (!iframe || !iframe.id || !window.YT || !window.YT.Player) return false

        try {
          // Check if player already exists
          if (iframe.contentWindow && iframe.contentWindow.postMessage) {
            // Use postMessage API for better compatibility
            const command = {
              event: 'command',
              func: action === 'pause' ? 'pauseVideo' : 
                    action === 'resume' ? 'playVideo' :
                    action === 'restart' ? 'seekTo' : 'playVideo',
              args: action === 'restart' ? [0] : []
            }
            
            iframe.contentWindow.postMessage(JSON.stringify(command), 'https://www.youtube.com')
            
            if (action === 'restart') {
              // After seeking to 0, play the video
              setTimeout(() => {
                const playCommand = { event: 'command', func: 'playVideo', args: [] }
                iframe.contentWindow.postMessage(JSON.stringify(playCommand), 'https://www.youtube.com')
              }, 100)
            }
            
            return true
          }
          return false
        } catch (error) {
          console.log("YouTube control error:", error)
          return false
        }
      },

      controlHTML5(action) {
        const videos = document.querySelectorAll('#media-player video')
        const audios = document.querySelectorAll('#media-player audio')
        
        // Convert NodeLists to arrays and combine
        const mediaElements = Array.from(videos).concat(Array.from(audios))
        
        mediaElements.forEach(media => {
          switch(action) {
            case 'pause':
              media.pause()
              break
            case 'resume':
              media.play()
              break
            case 'restart':
              media.currentTime = 0
              media.play()
              break
          }
        })
      },

      moveToCompleted(currentPlayingId) {
        // Find the current playing item in the queue and remove it
        const queueElement = document.querySelector(`#playlist #medium-${currentPlayingId}`)
        if (queueElement) {
          queueElement.remove()
        }
        
        // Don't add to completed section here - let the backend handle it
        // The completed section will be updated on page load or via separate broadcast
      },

      reinitializeAutoplay() {
        // Trigger autoplay controller to reinitialize with new media
        const autoplayController = document.querySelector('[data-controller*="autoplay"]')
        if (autoplayController && autoplayController.autoplay) {
          try {
            autoplayController.autoplay.setupAutoplay()
          } catch (error) {
            console.log("Error reinitializing autoplay:", error)
          }
        }
      }
    })
  }
})

  