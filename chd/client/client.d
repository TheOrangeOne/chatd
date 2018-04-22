import std.stdio : stdout, writefln, writef, readln;
import std.socket;
import std.concurrency;
import chd.client.crypto;


enum SERVER_NAME = "localhost";
enum SERVER_PORT = 6969;
enum PROMPT = "> ";

struct CHDClient {
  Socket sock;
};

static void clientListener(shared Socket s) {
  Socket client = cast(Socket)s;
  char[2048] buffer;
  long received;
  while ((received = client.receive(buffer)) > 0) {
    writef("\b\b< %s\n%s", buffer[0..received], PROMPT);
    stdout.flush();
  }
}

void main() {
  writef("chd client: init crypto ");

  if (crypto_init() == -1) {
    writefln("❌");
    return;
  }
  writefln("✓");

  testing();

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

  writef(PROMPT);
  while (readln(buf)) {
    writef(PROMPT);
    client.send(buf[0..$-1]);
  }

  client.shutdown(SocketShutdown.BOTH);
  client.close();
}
