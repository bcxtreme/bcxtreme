#ifndef _SHA256_H
#define _SHA256_H

#ifndef uint8
#define uint8  unsigned char
#endif

#ifndef uint32
#define uint32 unsigned long int
#endif

typedef struct
{
    uint32 total[2];
    uint32 state[8];
    uint8 buffer[64];
}
sha256_context;

void sha256_starts( sha256_context *ctx );
void sha256_update( sha256_context *ctx, uint8 *input, uint32 length );
void sha256_finish( sha256_context *ctx, uint8 digest[32] );
void sha256_finishx( sha256_context *ctx, uint8 digest[32],uint8 setLength640);
void sha256_set_state(sha256_context *ctx, uint32 A, uint32 B,uint32 C,uint32 D,uint32 E,uint32 F,uint32 G,uint32 H);
#endif /* sha256.h */

