import std.stdio;
import std.socket;
import std.concurrency;

enum PORT = 6969;

struct CHDClient {
  int id;
  Tid tid;
  Socket sock;
}

struct CHDServer {
  int hid;
  Socket sock;
  CHDClient[] clients;

  this(ushort port) {
    this.sock = new TcpSocket();
    this.sock.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    this.sock.bind(new InternetAddress(port));
    this.sock.listen(1);
    this.clients.length = 128;
  }

  int genHid() {
    return this.hid++;
  }

  void addClient(Socket sock) {
    auto clientId = this.genHid();

    // assume no collisions for now
    if (clientId+1 >= this.clients.length) {
      this.clients.length *= 2;
    }

    auto client = &this.clients[clientId];
    client.sock = sock;
    client.id = this.genHid();
    client.tid = spawn(&clientHandler, cast(shared Socket)client.sock, client.id);
  }
}


static void clientHandler(shared Socket s, int id) {
  Socket client = cast(Socket)s;
  char[2048] buffer;
  string clientAddr = client.remoteAddress.toAddrString;

  writefln("chd server [%d]: client (%s) connected", id, clientAddr);

  long received;
  while ((received = client.receive(buffer)) > 0) {
    writefln("chd server [%d]: received %d bytes (%s)", id, received, buffer[0..received]);
  }

  writefln("chd server [%d]: client %s disconnected", id, clientAddr);
}


void main() {
  CHDServer serv = CHDServer(PORT);
  Socket ssock = serv.sock;

  writefln("chd server: %s started on port %s", ssock.hostName, ssock.localAddress.toPortString);

  // handle accepting new clients
  while (true) {
    Socket client = ssock.accept();

    serv.addClient(client);

  }
}
