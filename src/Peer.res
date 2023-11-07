type t

type iceServer = {
  url: string,
  credential?: string,
}

type config = {
  iceServers: array<iceServer>,
  sdpSemantics?: string,
}

type peerOptions = {
  key?: string,
  host?: string,
  port?: int,
  pingInterval?: int,
  path?: string,
  debug?: int,
  secure?: bool,
  config?: config,
}

type sdp

type serializationType = [#binary | #"binary-utf8" | #json | #none]

@new @module("peerjs")
external makePeer: (~id: string=?, ~config: peerOptions=?, unit) => t = "Peer"

module DataConnection = {
  type d

  @send external send: (d, 'data) => unit = "send"
  @send external close: (d, _) => unit = "close"
  @send
  external on: (
    d,
    @string
    [
      | #"open"(unit => unit)
      | #close(unit => unit)
      | #data('data => unit)
      | #error(Js.Exn.t => unit)
    ],
  ) => unit = "on"

  @get external dataChannel: d => Js.Json.t = "dataChannel"
  @get external label: d => string = "label"
  @get external metadata: d => Js.Json.t = "metadata"
  @get external isOpen: d => bool = "open"
  @get external peerConnection: d => Js.Json.t = "peerConnection"
  @get external peer: d => string = "peer"
  @get external reliable: d => bool = "reliable"
  @get external serialization: d => serializationType = "serialization"
  @get external type_: d => string = "type"
  @get external bufferSize: d => int = "bufferSize"
}

module MediaConnection = {
  type m
  type mediaAnswerOptions = {sdpTransform: sdp => sdp}

  @send
  external answer: (m, ~stream: 'stream, ~options: mediaAnswerOptions=?, unit) => unit = "answer"
  @send external close: (m, unit) => unit = "close"
  @send
  external on: (
    m,
    @string
    [
      | #stream('stream => unit)
      | #close(unit => unit)
      | #error(Js.Exn.t => unit)
    ],
  ) => unit = "on"

  @get external isOpen: m => bool = "open"
  @get external metadata: m => Js.Json.t = "metadata"
  @get external peer: m => string = "peer"
  @get external type_: m => string = "type"
}

type connectOptions = {
  label?: string,
  metadata?: Js.Json.t,
  serialization?: serializationType,
  reliable?: bool,
}

type callOptions = {
  metadata?: Js.Json.t,
  sdpTransform?: sdp => sdp,
}

@send
external connect: (t, ~id: string, ~options: connectOptions=?, unit) => DataConnection.d = "connect"
@send
external call: (
  t,
  ~id: string,
  ~stream: 'stream,
  ~options: callOptions=?,
  unit,
) => MediaConnection.m = "call"
@send external disconnect: (t, unit) => unit = "disconnect"
@send external destroy: (t, unit) => unit = "destroy"
@send external reconnect: (t, unit) => unit = "reconnect"

@get external id: t => string = "id"
@get external disconnected: t => bool = "disconnected"
@get external destroyed: t => bool = "destroyed"

// TODO: add `err.type`` https://peerjs.com/docs/#peeron-error
@send
external on: (
  t,
  @string
  [
    | #"open"(string => unit)
    | #connection(DataConnection.d => unit)
    | #call(MediaConnection.m => unit)
    | #close(unit => unit)
    | #disconnected(unit => unit)
    | #error(Js.Exn.t => unit)
  ],
) => unit = "on"
