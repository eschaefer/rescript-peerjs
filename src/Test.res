// Test util
type stream
@new external makeStream: unit => stream = "MediaStream"

// Peer

let peerWithNoConfig = Peer.makePeer()
let peerWithConfig = Peer.makePeer(
  (),
  ~config={
    debug: 3,
    secure: true,
  },
)
let peerWithId = Peer.makePeer(~id="some-id", ())

peerWithId->Peer.destroy()
peerWithConfig->Peer.disconnect()
peerWithNoConfig->Peer.reconnect()

let peerId = peerWithConfig->Peer.id
let isPeerDisconnected = peerWithNoConfig->Peer.disconnected
let isPeerDestroyed = peerWithNoConfig->Peer.destroyed

// DataConnection

let connectionWithNoOptions = peerWithId->Peer.connect(~id="another-peer-id", ())
let connectionWithOptions = peerWithConfig->Peer.connect(
  ~id="another-peer-id",
  ~options={
    reliable: true,
    serialization: #binary,
  },
  (),
)

connectionWithOptions->Peer.DataConnection.send("Hello, world!")
connectionWithNoOptions->Peer.DataConnection.close()

connectionWithOptions->Peer.DataConnection.on(
  #"open"(
    _ => {
      Js.log("Connection opened")
    },
  ),
)
connectionWithNoOptions->Peer.DataConnection.on(
  #close(
    _ => {
      Js.log("Connection closed")
    },
  ),
)
connectionWithOptions->Peer.DataConnection.on(
  #data(
    data => {
      Js.log2("Received data", data)
    },
  ),
)
connectionWithNoOptions->Peer.DataConnection.on(
  #error(
    error => {
      Js.log2("Received error", error)
    },
  ),
)

let dataChannel = connectionWithOptions->Peer.DataConnection.dataChannel
let isConnectionOpen = connectionWithOptions->Peer.DataConnection.isOpen
let metadata = connectionWithNoOptions->Peer.DataConnection.metadata
let peerConnection = connectionWithOptions->Peer.DataConnection.peerConnection
let connectionPeerId = connectionWithNoOptions->Peer.DataConnection.peer
let reliable = connectionWithOptions->Peer.DataConnection.reliable
let serialization = connectionWithOptions->Peer.DataConnection.serialization
let connectionType = connectionWithNoOptions->Peer.DataConnection.type_
let bufferSize = connectionWithOptions->Peer.DataConnection.bufferSize

// MediaConnection

let stream = makeStream()
let mediaConnectionWithNoOptions = peerWithId->Peer.call(~id="another-peer-id", ~stream, ())
let mediaConnectionWithOptions = peerWithConfig->Peer.call(
  ~id="another-peer-id",
  ~stream,
  ~options={
    sdpTransform: sdp => sdp,
  },
  (),
)

mediaConnectionWithOptions->Peer.MediaConnection.on(
  #stream(
    stream => {
      Js.log2("Received stream", stream)
    },
  ),
)
mediaConnectionWithNoOptions->Peer.MediaConnection.on(
  #close(
    _ => {
      Js.log("Connection closed")
    },
  ),
)
mediaConnectionWithOptions->Peer.MediaConnection.on(
  #error(
    error => {
      Js.log2("Received error", error)
    },
  ),
)

mediaConnectionWithNoOptions->Peer.MediaConnection.answer(~stream, ())
mediaConnectionWithOptions->Peer.MediaConnection.answer(
  ~stream,
  ~options={
    sdpTransform: sdp => sdp,
  },
  (),
)
mediaConnectionWithNoOptions->Peer.MediaConnection.close()
mediaConnectionWithOptions->Peer.MediaConnection.close()

let isMediaConnectionOpen = mediaConnectionWithOptions->Peer.MediaConnection.isOpen
let mediaMetadata = mediaConnectionWithNoOptions->Peer.MediaConnection.metadata
let mediaPeerId = mediaConnectionWithOptions->Peer.MediaConnection.peer
let mediaType = mediaConnectionWithNoOptions->Peer.MediaConnection.type_
