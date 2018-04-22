module chd.client.crypto;

import std.stdio;

extern (C) int sodium_init();
extern (C) ubyte *sodium_bin2hex(ubyte *hex, ulong hex_maxlen, const ubyte *bin,
                                 ulong bin_len);
extern (C) void randombytes_buf(ubyte * buf, ulong size);
extern (C) ulong crypto_box_publickeybytes();
extern (C) ulong crypto_box_secretkeybytes();
extern (C) ulong crypto_box_macbytes();
extern (C) ulong crypto_box_noncebytes();
extern (C) int crypto_box_keypair(ubyte *pk, ubyte *sk);
extern (C) int crypto_box_easy(ubyte *c, const ubyte *m, ulong mlen,
                               const ubyte *n, const ubyte *pk,
                               const ubyte *sk);
extern (C) int crypto_box_open_easy(ubyte *m, const ubyte *c, ulong clen,
                                    const ubyte *n, const ubyte *pk,
                                    const ubyte *sk);


ulong PK_SIZE; //  = crypto_box_publickeybytes();
ulong SK_SIZE; //  = crypto_box_secretkeybytes();
ulong NO_SIZE; //  = crypto_box_noncebytes();

int crypto_init() {
  PK_SIZE = crypto_box_publickeybytes();
  SK_SIZE = crypto_box_secretkeybytes();
  NO_SIZE = crypto_box_noncebytes();
  return sodium_init();
}


void testing() {
  ubyte[] pk, sk, no;

  pk.length = PK_SIZE;
  sk.length = SK_SIZE;
  no.length = NO_SIZE;

  randombytes_buf(no.ptr, no.length);

  crypto_box_keypair(pk.ptr, sk.ptr);

  ubyte[] pk_hex, sk_hex;
  pk_hex.length = PK_SIZE*2 + 1;
  sk_hex.length = SK_SIZE*2 + 1;
  sodium_bin2hex(pk_hex.ptr, pk_hex.length, pk.ptr, pk.length);
  sodium_bin2hex(sk_hex.ptr, sk_hex.length, sk.ptr, sk.length);

  writefln("chd client: public key\n%s", cast(string)pk_hex);
  writefln("chd client: secret key\n%s", cast(string)sk_hex);


  ubyte[] msg = cast(ubyte[])"test";

  ubyte[] cipher;
  cipher.length = crypto_box_macbytes() + msg.length;

  crypto_box_easy(cipher.ptr, msg.ptr, msg.length, no.ptr, pk.ptr, sk.ptr);

  ubyte[100] umsg;
  auto ret = crypto_box_open_easy(umsg.ptr, cipher.ptr, cipher.length, no.ptr, pk.ptr, sk.ptr);
  writefln("chd client: %d %s", ret, cast(string)umsg);

  return;
}
