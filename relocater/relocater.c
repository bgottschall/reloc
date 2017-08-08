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

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdbool.h>
#include <ctype.h>
#include <getopt.h>

#include "relocater.h"
#include "bitstreams.h"


const char SYNC_WORD[] = { '\xAA', '\x99', '\x55', '\x66' };
const char HEADER_DELIMIT[] = { '\x61', '\x00' };
const char HEADER_DELIMITER_INCREMENT[] = { '\x01', '\x00' };

const char BUS_WIDTH_AUTO_DETECTION_PATTERN[] = { '\xFF', '\xFF', '\xFF', '\xFF',
                                                '\x00', '\x00', '\x00', '\xBB' };
#define BUS_WIDTH_AUTO_DETECTION_LENGTH 20 * sizeof(char)
#define HEADER_NODE_INDEX_START '\x61'


enum command { help, header, patch, create };
enum command todo = help;

struct binary_data {
    void *data;
    size_t length;
};

struct header_node {
    char index;
    struct binary_data value;
    struct header_node *next;
};

struct header_dump {
    struct binary_data bus_width_auto_detection;
    struct header_node *nodes;
};



bool is_string(char *data, size_t length) {
    if (length == 0) {
        return false;
    }
    if (data[length-1] != '\x00' ) {
        return false;
    }
    for (int i = 0; i < length-1; i++) {
        if (!isprint(data[i])) {
            return false;
        }
    }
    return true;
}


void fprintf_hd(FILE *stream, void *mem, int size) {
    unsigned char *p = (unsigned char *)mem;
    for (int i=0;i<size;i++) {
        fprintf(stream, "%02x ", p[i]);
        if ( i % 4 == 3 && i < (size-1)) {
            fprintf(stream, "\n");
        }
    }
}

struct far_profile {
    char address[4];
};

unsigned int far_profile_count = 0;

unsigned int far_index = 0;
struct far_profile *far_profiles = NULL;
bool parse_error = false;

int parse_package_far( void *package, void *payload) {
    struct BITSTREAM_PACKAGE far = create_package(package);
    if (far.word_count != 1) {
        fprintf(stderr, "FAR Package: wrong word count %d\n", far.word_count);
        return 1;
    }
    if ( todo == create ) {
        if (far_profiles == NULL) {
            far_index = 0;
            far_profile_count = 0;
            far_profiles = malloc(sizeof(struct far_profile) * (far_index + 1));
        } else {
            far_index++;
            far_profiles = realloc(far_profiles, sizeof(struct far_profile) * (far_index + 1));
        }
        if (far_profiles == NULL) {
            fprintf(stderr, "Could not allocate memory!\n");
            return 1;
        }
        far_profile_count++;
        memcpy((void *) &far_profiles[far_index], payload, PACKAGE_SIZE);
        fprintf(stdout,"Extracted FAR Address #%i: ", far_profile_count);
        fprintf_hd(stdout, payload, PACKAGE_SIZE);
        fprintf(stdout,"\n");
        return 0;
    }
    if ( todo == patch ) {
        if (far_index >= far_profile_count) {
            fprintf(stderr, "Not enough FAR Addresses in FAR Profile!\n");
            return 1;
        }
        fprintf(stdout,"Patching FAR Address #%i: ", (far_index+1));
        fprintf_hd(stdout, payload, PACKAGE_SIZE);
        fprintf(stdout, " -> ");
        fprintf_hd(stdout, (void *) &far_profiles[far_index], PACKAGE_SIZE);
        fprintf(stdout, "\n");
        memcpy(payload, (void *) &far_profiles[far_index], PACKAGE_SIZE);
        far_index++;
    }
    if ( todo == header ) {
        fprintf(stdout,"FAR Address #%i: ", (far_index+1));
        fprintf_hd(stdout, payload, PACKAGE_SIZE);
        fprintf(stdout, "\n");
        far_index++;
    }
    return 0;
};

typedef struct
{
    unsigned int type;
    unsigned int opcode;
    unsigned int register_address;
    int (*parse_package) (void *package, void *payload);
} parsetab;

static const parsetab parsing[] =
{
    { TYPE_1, OPCODE_READ,  REGISTER_FAR, parse_package_far },
    { TYPE_1, OPCODE_WRITE, REGISTER_FAR, parse_package_far },
};


void free_header_dump(struct header_dump *dump) {
    struct header_node *node,*old_node;
    if (dump != NULL) {
        node = dump->nodes;
        while (node != NULL) {
            old_node = node;
            node = node->next;
            free(old_node);
        }
        free(dump);
    }

}



struct header_dump *create_header_dump(char *data, size_t length) {
    char *sync_pos = kmemmem(data, length, SYNC_WORD, sizeof(SYNC_WORD));
    char *bus_pos = kmemmem(data, length, BUS_WIDTH_AUTO_DETECTION_PATTERN, sizeof(BUS_WIDTH_AUTO_DETECTION_PATTERN));
    char header_index = HEADER_NODE_INDEX_START;
    char header_field[2] =  { HEADER_NODE_INDEX_START, '\x00' };
    const size_t header_field_size = sizeof(header_field) + sizeof(char);
    bool traverse = false;
    if (sync_pos == NULL || bus_pos == NULL) {
        return NULL;
    }

    struct header_dump *dump = malloc(sizeof(struct header_dump));
    dump->nodes = NULL;
    dump->bus_width_auto_detection.data = bus_pos;
    dump->bus_width_auto_detection.length = BUS_WIDTH_AUTO_DETECTION_LENGTH;

    size_t max_length = (size_t) bus_pos - (size_t) data;
    char *pos1 = kmemmem(data, max_length, header_field, sizeof(header_field));
    char *pos2 = NULL;
    if (pos1 != NULL) {
        traverse = true;
        pos1 += header_field_size;
    }

    struct header_node *old_node = NULL;
    while (traverse) {
        struct header_node *new_node = malloc(sizeof(struct header_node));
        new_node->index = header_index;
        new_node->next = NULL;

        header_index++;
        header_field[0] = header_index;
        pos2 = kmemmem(data, max_length, header_field, sizeof(header_field));
        if (pos2 == NULL) {
            pos2 = bus_pos;
            traverse = false;
        }

        new_node->value.data = pos1;
        new_node->value.length = (size_t) pos2 - (size_t) pos1;
        if (dump->nodes == NULL) {
            dump->nodes = new_node;
        } else {
            old_node->next = new_node;
        }
        old_node = new_node;
        pos1 = (char *) ((size_t) pos2 + header_field_size);
    }
    return dump;
}

void output_header_dump(struct header_dump *dump) {
    struct header_node *node;
    if (dump == NULL) {
        fprintf(stderr, "Invalid Header Dump!");
        return;
    }
    node = dump->nodes;
    while (node != NULL) {
        fprintf(stdout, "Header %c: ", node->index);
        if (is_string(node->value.data, node->value.length)) {
            fprintf(stdout, "%s\n", (char *)node->value.data);
        } else {
            fprintf(stdout, "\n");
            fprintf_hd(stdout, node->value.data, node->value.length);
            fprintf(stdout,"\n\n");
        }

        node = node->next;
    }
    fprintf(stdout, "Bus Width Auto Detection Pattern:\n");
    fprintf_hd(stdout, dump->bus_width_auto_detection.data, dump->bus_width_auto_detection.length);
    fprintf(stdout,"\n\n");
}



void hfree(void * pointer) {
    if (pointer != NULL) {
        free(pointer);
    }
}

void usage(void) {
    printf("Usage: relocater [-d] [-c|-p profile] bitstream\n");
    printf("\t-d\t\tDump Bitstream Header\n");
    printf("\t-c profile\tcreate frame address profile from bitstream\n");
    printf("\t-p profile\tpatch frame address profile to bitstream\n");
    printf("\t-h\t\tshow this help page\n");
}

int main(int argc, char **argv) {
    struct binary_data file_buffer;
    struct binary_data bitstream;
    struct binary_data far_file;
    far_file.data = NULL;
    file_buffer.data=NULL;
    FILE *fp;
    struct header_dump *dump;
    char *frame_profile_filename = NULL;
    char *bitstream_filename = NULL;
    int c;


    if (argc < 2) {
        goto usage;
    }

    while ((c = getopt(argc, argv, "hdc:p:")) != -1) {
        switch (c) {
            case 'd':
                todo = header;
                break;
            case 'p':
                todo = patch;
                frame_profile_filename = strdup(optarg);
                break;
            case 'c':
                todo = create;
                frame_profile_filename = strdup(optarg);
                break;
            case '?':
                todo = help;
                goto usage;
                break;
            case 'h':
                todo = help;
                goto usage;
                break;
            break;

            default:
                printf("?? getopt returned character code 0%o ??\n", c);
        }
    }

    if (todo == help) {
        goto usage;
    }

    if (optind >= argc) {
       fprintf(stderr,"No Bitstream provided!\n");
       goto usage;
    }

    bitstream_filename = strdup(argv[optind]);

    if( access( bitstream_filename, W_OK ) == -1 ) {
        fprintf(stderr, "Bitstream %s not found!\n",bitstream_filename);
        goto error_early;
    }

    struct stat info;

    if (todo == patch) {
        if( access( frame_profile_filename, R_OK ) == -1 ) {
            fprintf(stderr, "Frame address profile %s not found!\n",bitstream_filename);
            goto error_early;
        }
        stat(frame_profile_filename, &info);
        far_file.length = info.st_size;
        fp = fopen(frame_profile_filename, "r+b");
        if (fp == NULL) {
            fprintf(stderr, "Cannot open far profile %s!\n", frame_profile_filename);
            goto error_early;
        }
        far_file.length = info.st_size;
        if (far_file.length % 4 != 0) {
            fprintf(stderr, "Incorrect FAR Profile!\n");
            goto error;
        }
        far_file.data = (char *) malloc (far_file.length * sizeof(char));
        if (far_file.data == NULL) {
            fprintf(stderr, "Could not allocate memory!\n");
            goto error;
        }
        if ( fread(far_file.data, far_file.length, 1, fp) != 1 ) {
            fprintf(stderr, "Could not read whole bitstream!\n");
            goto error;
        }
        fclose(fp);
        far_profile_count = far_file.length / sizeof(struct far_profile);
        far_profiles = (struct far_profile *)far_file.data;
        fprintf(stdout, "%u FAR Addresses found for patching!\n", far_profile_count);
    }


    stat(bitstream_filename, &info);

    fp = fopen(bitstream_filename, "r+b");
    if (fp == NULL) {
        fprintf(stderr, "Cannot open bitstream %s!\n", bitstream_filename);
        goto error_early;
    }
    file_buffer.length = info.st_size;
    file_buffer.data = (char *) malloc (file_buffer.length * sizeof(char));
    if (file_buffer.data == NULL) {
        fprintf(stderr, "Could not allocate memory!\n");
        goto error;
    }
    if ( fread(file_buffer.data, file_buffer.length, 1, fp) != 1 ) {
        fprintf(stderr, "Could not read whole bitstream!\n");
        goto error;
    }
    fclose(fp);


    dump = create_header_dump(file_buffer.data, file_buffer.length);

    if (dump == NULL) {
        fprintf(stderr, "Invalid Bitstream Header!\n");
        goto error;
    }

    if (todo == header) {
        output_header_dump(dump);
    }

    bitstream.data = kmemmem(file_buffer.data, file_buffer.length, SYNC_WORD, sizeof(SYNC_WORD));
    if (bitstream.data == NULL) {
        fprintf(stderr, "Invalid Bitstream Header!\n");
        goto error;
    }
    bitstream.data += sizeof(SYNC_WORD);
    bitstream.length = file_buffer.length - ((size_t) bitstream.data - (size_t) file_buffer.data);


    unsigned int processed_length = 0;
    unsigned int package_length = 0;
    const unsigned int parsing_size = sizeof(parsing) / sizeof(parsing[0]);
    struct BITSTREAM_PACKAGE package;
    while (processed_length < bitstream.length) {
        if (processed_length + PACKAGE_SIZE > bitstream.length) {
            fprintf(stderr, "Unexpected bitstream ending!");
            goto error;
        }
        package = create_package(bitstream.data);

        for (int i = 0; i < parsing_size; i++) {
            if (parsing[i].type == package.type &&
                parsing[i].opcode == package.opcode &&
                parsing[i].register_address == package.register_address) {
                    if (parsing[i].parse_package((void *) bitstream.data, (void *) ((size_t) bitstream.data + PACKAGE_SIZE))) {
                        fprintf(stderr,"Error occured while parsing bitstream package!\n");
                        goto error;
                    }
                    break;
            }
        }
        package_length = (1 + package.word_count) * PACKAGE_SIZE;
        processed_length += package_length;
        bitstream.data = (void *) ((size_t) bitstream.data + package_length);
    }

    if ( todo == create ) {
        fp = fopen(frame_profile_filename, "w+b");
        if (fp == NULL) {
            fprintf(stderr, "Cannot open FAR profile file %s!\n", frame_profile_filename);
            goto error;
        }
        if ( fwrite((void *)far_profiles, far_profile_count * sizeof(struct far_profile), 1, fp) != 1 ) {
            fprintf(stderr, "Could not write FAR profile!\n");
            goto error;
        }
        fclose(fp);
        fprintf(stdout, "FAR Profile saved to %s\n", frame_profile_filename);
    }

    if ( todo == patch ) {
        if (far_index != far_profile_count) {
            fprintf(stderr,"Not all FAR Addresses from profile were patched. Will not save bitstream!\n");
            goto error;
        }
        fp = fopen(bitstream_filename, "w+b");
        if (fp == NULL) {
            fprintf(stderr, "Cannot open bitstream file %s!\n", bitstream_filename);
            goto error;
        }
        if ( fwrite(file_buffer.data, file_buffer.length, 1, fp) != 1 ) {
            fprintf(stderr, "Could not write bitstream file!\n");
            goto error;
        }
        fclose(fp);
        fprintf(stdout, "Bitstream saved to %s\n", bitstream_filename);
    }


done:
    free_header_dump(dump);
    hfree(file_buffer.data);
    hfree(far_file.data);
    hfree(frame_profile_filename);
    hfree(bitstream_filename);
    hfree(far_profiles);
    exit(EXIT_SUCCESS);

error:
    hfree(far_profiles);
    free_header_dump(dump);
    hfree(file_buffer.data);
    hfree(far_file.data);
error_early:
    hfree(frame_profile_filename);
    hfree(bitstream_filename);
    exit(EXIT_FAILURE);

usage:
    usage();
    hfree(frame_profile_filename);
    hfree(bitstream_filename);
    exit(EXIT_SUCCESS);
}
