import std.stdio;
import std.socket;
import std.concurrency;
import std.uuid;

enum PORT = 6969;

struct CHDClient {
  UUID id;
  Tid tid;
  Socket sock;

  this(Socket sock) {
    this.id   = randomUUID();
    this.sock = sock;
    this.tid  = spawn(&clientHandler, cast(shared Socket)sock, this.id);
  }
}

struct CHDServer {
  Socket sock;
  CHDClient*[UUID] clients;

  this(ushort port) {
    this.sock = new TcpSocket();
    this.sock.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    this.sock.bind(new InternetAddress(port));
    this.sock.listen(1);
  }


  void addClient(Socket sock) {
    auto id = randomUUID();
    auto client = new CHDClient(sock);
    this.clients[client.id] = client;
  }
}


static void clientHandler(shared Socket s, UUID id) {
  Socket client = cast(Socket)s;
  char[2048] buffer;
  string clientAddr = client.remoteAddress.toAddrString;

  writefln("chd server [%s]: client (%s) connected", id, clientAddr);

  long received;
  while ((received = client.receive(buffer)) > 0) {
    writefln("chd server [%s]: received %d bytes (%s)", id, received, buffer[0..received]);
    client.send(buffer[0..received]);
  }

  writefln("chd server [%s]: client %s disconnected", id, clientAddr);
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
