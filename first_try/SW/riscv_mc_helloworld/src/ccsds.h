#include <stdint.h>
// Define a structure for the main CCSDS Packet Frame header
typedef struct {
    uint8_t version_number : 3;     // CCSDS Version Number (3 bits)
    uint8_t packet_type : 1;        // Packet Type (1 bit)
    uint8_t second_header_flag : 1; // 2nd Header Flag (1 bit)
    uint16_t app_id : 11;           // Application ID (11 bits)
    uint8_t group_flag : 2;         // Packet Group Flag (2 bits) AKA sequence flag
    uint16_t sequence_number : 14;  // Sequence Number (14 bits)
    uint16_t data_length : 16;      // Data Length (16 bits)   (Total Number of Octets in the Packet Data Field) – 1
} __attribute__ ((aligned (1), packed)) CCSDS_Packet_Header;
// Define a structure for the CCSDS 2nd Header
typedef struct {
    uint64_t timing_info : 48;      // Timing Info (48 bits)
    uint8_t segment_number : 8;     // Segment Number (8 bits)
    uint8_t function_code : 8;      // Function Code (8 bits)
    uint16_t address_code : 16;     // Address Code (16 bits)
} __attribute__ ((aligned (1), packed)) CCSDS_Second_Header;
// Define a structure for the entire CCSDS Packet Frame
typedef struct {
    CCSDS_Packet_Header primary_header;   // Primary header
    CCSDS_Second_Header secondary_header; // Secondary header
    uint8_t *cmd_or_tlm_data;             // Telemetry or Command Data (variable length)
    uint32_t crc_checksum;                // CRC32 Checksum (32 bits)
} __attribute__ ((aligned (1), packed)) CCSDS_Packet_Frame;


#define PKG_VER_NUM_1		  0b000
#define PKT_TYPE_TM			  0b0
#define PKT_TYPE_TC			  0b1

#define APID_IDLE 0b1111111111

// Define the Sequence Flags for CCSDS Packet
#define SEQ_FLAG_CONTINUATION 0b00  // Continuation segment of User Data
#define SEQ_FLAG_FIRST        0b01  // First segment of User Data
#define SEQ_FLAG_LAST         0b10  // Last segment of User Data
#define SEQ_FLAG_UNSEGMENTED  0b11  // Unsegmented User Data
