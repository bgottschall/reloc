// Copyright (c) 2017 Björn Gottschall <github.mail@bgottschall.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//This is a Proof of Concept, not clean code!

#include <endian.h>
#include <stdint.h>

#define TYPE_1 0b001
#define TYPE_2 0b010

#define OPCODE_NOP      0b00
#define OPCODE_READ     0b01
#define OPCODE_WRITE    0b10
#define OPCODE_RESERVED 0b11

#define REGISTER_CRC        0b00000
#define REGISTER_FAR        0b00001
#define REGISTER_FDRI       0b00010
#define REGISTER_FDRO       0b00011
#define REGISTER_CMD        0b00100
#define REGISTER_CTL0       0b00101
#define REGISTER_MASK       0b00110
#define REGISTER_STAT       0b00111
#define REGISTER_LOUT       0b01000
#define REGISTER_COR0       0b01001
#define REGISTER_MFWR       0b01010
#define REGISTER_CBC        0b01011
#define REGISTER_IDCODE     0b01100
#define REGISTER_AXSS       0b01101
#define REGISTER_COR1       0b01110
#define REGISTER_WBSTAR     0b10000
#define REGISTER_TIMER      0b10001
#define REGISTER_BOOTSTS    0b10110
#define REGISTER_CTL1       0b11000
#define REGISTER_BSPI       0b11111
#define REGISTER_BSPI_READ  0b10010
#define REGISTER_FALL_EDGE  0b10011


#define REGISTER_INVALID    -1

#define PACKAGE_SIZE 4

struct BITSTREAM_PACKAGE {
    unsigned int type; //E0
    unsigned int opcode; //2
    //
    unsigned int register_address; // 5
    unsigned int word_count; // 11 - 27
};


//    WWWW WWWW AAAR RWWW RRRR RRAA TTTO ORRR
// 00000RRRRRRRRR00000RR00000000000
// 00100000000000000000000000000000
// 00001000000000000000000000000000
// 00000010000000000000000000000000
// 00000010000000000000000000000000
struct BITSTREAM_PACKAGE create_package(void *data) {
    struct BITSTREAM_PACKAGE package;
    char *values = (char *) data;
    uint32_t value = be32toh(*((uint32_t *)data));
    package.type = (value & 0xE0000000) >> 29;
    package.opcode = (value & 0x18000000) >> 27;
    if (package.type == TYPE_1) {
        package.register_address = (value & 0x0003E000) >> 13;
        package.word_count = (value & 0x000007FF);
    } else {
        package.register_address = REGISTER_INVALID;
        package.word_count = (value & 0x7FFFFFF);
    }
    return package;
}

void dump_package(struct BITSTREAM_PACKAGE package) {
    printf("Package Type:\t\t\t%d\n", package.type);
    printf("Package OpCode:\t\t\t0x%x\n", package.opcode);
    printf("Package Register Address:\t0x%x\n", package.register_address);
    printf("Package Word Count:\t\t0x%x\n", package.word_count);
}
