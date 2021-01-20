use "net"
use "buffered"

class MyUDPNotify is UDPNotify
  let _cb: Main
  let _out: OutStream
  let _destination: NetAddress

  new create(
    out: OutStream,
    destination: NetAddress,
    cb: Main)
  =>
    _out = out
    _destination = destination
    _cb = cb

  fun ref listening(sock: UDPSocket ref) =>
    _cb.send_fast(recover tag sock end, _destination)

  fun ref received(
    sock: UDPSocket ref,
    data: Array[U8] iso,
    from: NetAddress)
  =>
    None

  fun ref not_listening(sock: UDPSocket ref) =>
    _out.print("client not ready to send")
    None

  fun ref closed(sock: UDPSocket ref) =>
    _out.print("Client closed")
    None

actor Main
  let _env: Env
  var _n_packets: USize = 0

  new create(env: Env) =>
    _env = env
    try
      let host = "0.0.0.0"
      let service = "0"
      let dest_host = env.args(1)?
      let dest_port = env.args(2)?
      _n_packets = env.args(3)?.usize() ?
      let dest = recover val
        DNS.ip4(env.root as AmbientAuth,
                dest_host,
                dest_port)
      end
      UDPSocket.ip4(where
        auth = env.root as AmbientAuth,
        notify = recover MyUDPNotify(env.out, dest(0)?, this) end,
        host = host,
        service = service)
    else
      env.err.print("./client dest_ip dest_port packets_to_send")
    end

  be send_fast(sock: UDPSocket, to: NetAddress) =>
    var packets_sent: USize = 0
    let w = Writer
    let buffer = recover val Array[U8].init(0, 1000) end
    while packets_sent < _n_packets do
      w.u64_be(buffer.size().u64())
      w.write(buffer)
      sock.writev(w.done(), to)
      packets_sent = packets_sent + 1
    end
    _env.out.print("Done sending")
    sock.dispose()
