
/*
 * take user input string, parse and implement command
 */

#include <stdio.h>
#include <string.h>

static unsigned char memory[64] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f,
    0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f,
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f
};

static void execute_command(int items_count, const char* cmd, unsigned int addr, unsigned int val);

void parse_input(const char input[]) {
    char cmd[128];
    uint32_t addr, val = 0;
    int items_read = 0;

printf("%s\n",input);

    items_read = sscanf(input, "%s %x %x", cmd, &addr, &val);
printf("items_read: %d\n", items_read);

    if (items_read != 0 ) {
        execute_command(items_read, cmd, addr, val);
    }
}

void help(void) {
    printf("valid command:\n"
           "r address(hex)                ## read 32bits from address\n"
           "w address(hex) value          ## write value(32bits) to address\n"
           "m address(hex) count          ## read  from address up to the count \n"
           "s address(hex) count value    ## write value(32bits) to address\n"
           "?                             ## help\n");
}

void execute_command(int items_count, const char* cmd, unsigned int addr, unsigned int val) {
    if (strcmp(cmd, "r") == 0 && items_count == 2) {
    	if( addr%4 == 0){
    		printf("Read uint32_t from address 0x%x\n", addr);
    		uint32_t *p = (uint32_t*)addr;
    		printf("[%p] : %08x\n", p, (unsigned int)(*p));
    	} else {
    		printf("address must align 4 bytes, in order to read uint32\n");
    	}


    } else
    if (strcmp(cmd, "r16") == 0 && items_count == 2) {
    	if( addr%2 == 0 ){
    		printf("Read uint16_t from address 0x%x\n", addr);
    		uint16_t *p = (uint16_t*)&memory[addr];
    		printf("[%p] : %04x\n", p, (unsigned int)(*p));
    	}else {
    		printf("address must align 4 bytes, in order to read uint32\n");
    	}
    } else
    if (strcmp(cmd, "r8") == 0 && items_count == 2) {
        printf("Read uint8_t from address 0x%x\n", addr);
        uint8_t *p = (uint8_t*)&memory[addr];
        printf("[%p] : %02x\n", p, (unsigned int)(*p));
    } else
    if (strcmp(cmd, "m") == 0 && items_count == 3) {
    	if( addr%4 == 0 ){
    		printf("Read Array uint32_t from address 0x%x, count %d\n", addr, val);

    		uint32_t *p = (uint32_t*)addr;
    		printf("[%p] :\n", p);
    		for( int i = 0; i < val; i++ ){
    			printf("%08x\n", (unsigned int)(*p));
    			p++;
    		}
    		printf("\n");
    	}else{
    		printf("address must align 4 bytes, in order to write uint32\n");
    	}
    } else
    if (strcmp(cmd, "m16") == 0 && items_count == 3) {
        printf("Read Array uint16_t from address 0x%x, count %d\n", addr, val);
        // Implement actual read operation here
    } else
    if (strcmp(cmd, "m8") == 0 && items_count == 3) {
        printf("Read Array uint8_t from address 0x%x, count %d\n", addr, val);
        // Implement actual read operation here
    } else
    if (strcmp(cmd, "w") == 0 && items_count == 3) {
    	if( addr%4 == 0 ){
    		printf("Writing value(4 bytes) %x to address 0x%x\n", val, addr);
    		uint32_t *p = (uint32_t*)addr;
    		*p = val;
    	}else{
    		printf("address must align 4 bytes, in order to write uint32\n");
    	}
    } else
    if (strcmp(cmd, "w16") == 0 && items_count == 3) {
        printf("Writing value(2 bytes) %x to address 0x%x\n", val, addr);
        uint16_t *p = (uint16_t*)&memory[addr];
        *p = val;
    } else
    if (strcmp(cmd, "w8") == 0 && items_count == 3) {
        printf("Writing value(1 byte) %x to address 0x%x\n", val, addr);
        uint8_t *p = (uint8_t*)&memory[addr];
        *p = val;
    } else
    if (strcmp(cmd, "?") == 0) {
        help();
    }
    else {
        help();
    }
}



