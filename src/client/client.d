import std.stdio;
import std.socket;
import std.concurrency;


extern (C) int sodium_init();
extern (C) ubyte *sodium_bin2hex(ubyte *hex, ulong hex_maxlen, const ubyte * bin, ulong bin_len);
extern (C) void randombytes_buf(ubyte * buf, ulong size);
extern (C) ulong crypto_box_publickeybytes();
extern (C) ulong crypto_box_secretkeybytes();
extern (C) ulong crypto_box_noncebytes();
extern (C) int crypto_box_keypair(ubyte *pk, ubyte *sk);

enum SERVER_NAME = "localhost";
enum SERVER_PORT = 6969;
enum PROMPT = "> ";

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

  if (sodium_init() == -1) {
    writefln("❌");
    return;
  }
  writefln("✓");

  ubyte[] pk, sk;
  auto PK_SIZE = crypto_box_publickeybytes();
  auto SK_SIZE = crypto_box_secretkeybytes();

  pk.length = PK_SIZE;
  sk.length = SK_SIZE;

  writef("chd client: generating key pair ");
  if (crypto_box_keypair(pk.ptr, sk.ptr)) {
    writefln("❌");
    return;
  }
  writefln("✓");

  ubyte[] pk_hex, sk_hex;
  pk_hex.length = PK_SIZE*2 + 1;
  sodium_bin2hex(pk_hex.ptr, pk_hex.length, pk.ptr, pk.length);
  writefln("chd client: public key\n%s\n", cast(string)pk_hex);

  return;

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
