use "net"
use "buffered"

class MyUDPNotify is UDPNotify
  let _out: OutStream
  var _packets_received: USize

  new create(out: OutStream) =>
    _out = out
    _packets_received = 0

  fun ref listening(sock: UDPSocket ref) =>
    _out.print("server listening")
    None

  fun ref received(
    sock: UDPSocket ref,
    data: Array[U8] iso,
    from: NetAddress)
  =>
    _packets_received = _packets_received + 1
    _out.print("Received " + _packets_received.string() + " packets")
    let rb = Reader.>append(consume data)
    try
      let buff_size = rb.u64_be() ?
      let buffer = rb.block(buff_size.usize()) ?
      _out.print("Received buffer of size " + buff_size.string())
    else
      _out.print("Received an error")
    end

  fun ref not_listening(sock: UDPSocket ref) =>
    _out.print("server not ready to receive")
    None

  fun ref closed(sock: UDPSocket ref) =>
    _out.print("Server closed")
    None

actor Main
  new create(env: Env) =>
    try
      let args = env.args
      let host: String = args(1)?
      let service: String = args(2)?
      env.out.print("Listening on " + host + ":" + service)
      UDPSocket.ip4(where
        auth = env.root as AmbientAuth,
        notify = recover MyUDPNotify(env.out) end,
        host = host,
        service = service)
    else
      env.err.print("./server ip port")
    end
