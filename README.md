To test this, first compile the server and client as such:

```bash
$ make
```

To run the server:

```
$ ./build/server <ip> <port>
```

To run the client:

```bash
$ ./build/client <server-ip> <server-port> <packets_to_send>
```

Ideally, test this on non-loopback interfaces. Under the new change, the server
should receive exactly `<packets_to_send>` packets from the client, and all should
decode successfully and print "Received buffer of size 1000".

On the old implementation, the server will receive more than `<packets_to_send>`
packets, and will probably error while decoding, or print "Received buffer of size 0".
