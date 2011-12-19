#include "sha256.h"
#include "stdio.h"
#include "stdint.h"

int main(int argc, const char** argv) {
sha256_context c;
uint8 digest[32];
//Test block from bitcoin wiki.
uint8 m[80]={0x01,0x00,0x00,0x00,0x81,0xcd,0x02,0xab,0x7e,0x56,0x9e,0x8b, 0xcd,0x93,0x17,0xe2,0xfe,0x99,0xf2,0xde,0x44,0xd4,0x9a,0xb2,0xb8,0x85,0x1b,0xa4,0xa3,0x08,0x00,0x00,0x00,0x00,0x00,0x00, 0xe3,0x20,0xb6,0xc2, 0xff,0xfc,0x8d,0x75, 
 0x04,0x23,0xdb,0x8b,0x1e,0xb9,0x42,0xae,0x71,0x0e,0x95,0x1e,0xd7,0x97,0xf7,0xaf, 0xfc,0x88,0x92,0xb0,0xf1,0xfc,0x12,0x2b,0xc7,0xf5,0xd7,0x4d,0xf2,0xb9,0x44,0x1a,0x00,0x00,0x00,0x00};

//Test vector from specification
uint8 m2[56]={
0x61,0x62,0x63,0x64,0x62,0x63,0x64,
0x65,0x63,0x64,0x65,0x66,0x64,0x65,
0x66,0x67,0x65,0x66,0x67,0x68,0x66,
0x67,0x68,0x69,0x67,0x68,0x69,0x6a,
0x68,0x69,0x6a,0x6b,0x69,0x6a,0x6b,
0x6c,0x6a,0x6b,0x6c,0x6d,0x6b,0x6c,
0x6d,0x6e,0x6c,0x6d,0x6e,0x6f,0x6d,
0x6e,0x6f,0x70,0x6e,0x6f,0x70,0x71
};
printf("%ld\n",sizeof(m));
sha256_starts(&c);
sha256_update( &c, (uint8*)m, 80);

sha256_finish( &c, digest);

printf("SHA is ");

for(int i=0; i<32;i++) {
  printf("%02x",((uint8*)digest)[i]);
}

printf("\n");
sha256_starts(&c);
sha256_update(&c,digest,32);
sha256_finish( &c, digest);

printf("Double SHA is ");

for(int i=0; i<32;i++) {
  printf("%02x",((uint8*)digest)[i]);
}

printf("\n");
return 0;
}
