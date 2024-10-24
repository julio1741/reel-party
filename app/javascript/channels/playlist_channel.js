import consumer from "./consumer"

  const playlistElement = document.getElementById('playlist')

  if (playlistElement) {
    const playlistId = playlistElement.dataset.playlistId

    consumer.subscriptions.create({ channel: "PlaylistChannel", playlist_id: playlistId }, {
      connected() {
        console.log("conectado al canal de PlaylistChannel")
        // Called when the subscription is ready for use on the server
      },
      received(data) {
        console.log(data)
        // Insertar el nuevo medium en la lista
        const mediaList = document.getElementById('playlist')
        mediaList.insertAdjacentHTML('beforeend', data.medium)
      }
    })
  }

  