import std.stdio;
import std.socket;
import std.concurrency;

enum SERVER_NAME = "localhost";
enum SERVER_PORT = 6969;

static void clientListener(shared Socket s) {
  Socket client = cast(Socket)s;
  char[2048] buffer;
  long received;
  while ((received = client.receive(buffer)) > 0) {
    writefln("< %s", buffer[0..received]);
  }
}


void main() {
  Socket client = new TcpSocket();
  client.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);

  writefln("chd client: connecting to proxy");

  auto addrs = getAddress(SERVER_NAME, SERVER_PORT);

  if (!addrs.length) {
    writefln("chd client: could not connect to server");
    return;
  }

  try {
    client.connect(addrs[0]);
  }
  catch (SocketOSException e) {
    writefln("chd client: could not connect to server");
    return;
  }

  spawn(&clientListener, cast(shared)client);

  char[] buf;

  writef("> ");
  while (readln(buf)) {
    writef("> ");
    client.send(buf[0..$-1]);
  }

  client.shutdown(SocketShutdown.BOTH);
  client.close();
}
