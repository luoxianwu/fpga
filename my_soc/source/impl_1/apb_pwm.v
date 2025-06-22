// File: APB_PWM.v
// Description: An APB-compliant Pulse Width Modulation (PWM) generator.
//              This module allows a CPU (via an APB bus) to configure the PWM
//              duty cycle and duration. It also provides status (done) back to the CPU.

module APB_PWM (
    // APB Slave Interface Ports
    input wire         pclk,        // APB Clock
    input wire         preset_n,    // APB Reset (active low)
    input wire  [31:0] paddr,       // APB Address
    input wire         psel,        // APB Select (active high)
    input wire         penable,     // APB Enable (active high, indicates second phase of transfer)
    input wire         pwrite,      // APB Write (1 for write, 0 for read)
    input wire  [31:0] pwdata,      // APB Write Data
    output reg  [31:0] prdata,      // APB Read Data
    output reg         pready,      // APB Ready (indicates transaction completion)
    output reg         pslverr,     // APB Slave Error (indicates an error during transfer)

    // PWM Output Ports
    output wire        pwm_out,     // Actual PWM output signal
    output wire        pwm_done     // Indicates completion of specified PWM duration
);

    // =========================================================================
    // Register Definitions (Accessible via APB)
    // =========================================================================
    // These registers store the configuration and status for the PWM.
    // Address Map (relative to APB_PWM base address, e.g., 0x00008800 as per my_soc.v)
    // 0x00: PWM_DUTY_CYCLE_REG [15:0] - Write to set duty cycle.
    // 0x04: PWM_DURATION_REG   [15:0] - Write to set duration (number of pulses).
    // 0x08: PWM_CONTROL_REG    [0]    - Bit 0: PWM_ENABLE (1 = enable, 0 = disable/reset PWM counters)
    // 0x0C: PWM_STATUS_REG     [0]    - Bit 0: PWM_DONE (Read-only, indicates duration complete)
    // =========================================================================

    reg  [15:0] pwm_duty_cycle_reg; // Stores the desired PWM duty cycle
    reg  [15:0] pwm_duration_reg;   // Stores the desired number of PWM pulses (duration)
    reg         pwm_enable_reg;     // Controls whether the PWM is active
    reg         pwm_done_status;    // Internal register from PWM core to capture done status (CHANGED from wire to reg)

    // =========================================================================
    // APB Slave Logic
    // =========================================================================
    // Default values for APB outputs
    always @(posedge pclk or negedge preset_n) begin
        if (!preset_n) begin
            pready  <= 1'b1;       // Default ready
            pslverr <= 1'b0;       // No error on reset
            prdata  <= 32'b0;      // Read data cleared
        end else begin
            pready  <= 1'b1;       // Be ready by default unless actively processing
            pslverr <= 1'b0;       // Clear error unless an invalid access occurs
            prdata  <= 32'b0;      // Default read data to 0

            // APB Write Cycle
            if (psel && penable && pwrite) begin
                case (paddr[3:0]) // Use bits 3:0 for byte addressing within the 32-bit word
                    4'h0: begin // Address 0x00: PWM_DUTY_CYCLE_REG
                        pwm_duty_cycle_reg <= pwdata[15:0]; // Only care about lower 16 bits
                    end
                    4'h4: begin // Address 0x04: PWM_DURATION_REG
                        pwm_duration_reg <= pwdata[15:0]; // Only care about lower 16 bits
                    end
                    4'h8: begin // Address 0x08: PWM_CONTROL_REG
                        pwm_enable_reg <= pwdata[0]; // Bit 0 is PWM_ENABLE
                    end
                    default: begin
                        // Invalid write address
                        pslverr <= 1'b1;
                    end
                endcase
            end
            // APB Read Cycle
            else if (psel && penable && !pwrite) begin
                case (paddr[3:0]) // Use bits 3:0 for byte addressing within the 32-bit word
                    4'h0: begin // Address 0x00: PWM_DUTY_CYCLE_REG
                        prdata <= {16'b0, pwm_duty_cycle_reg}; // Read the current duty cycle
                    end
                    4'h4: begin // Address 0x04: PWM_DURATION_REG
                        prdata <= {16'b0, pwm_duration_reg};   // Read the current duration
                    end
                    4'h8: begin // Address 0x08: PWM_CONTROL_REG
                        prdata <= {31'b0, pwm_enable_reg};     // Read PWM enable status
                    end
                    4'hC: begin // Address 0x0C: PWM_STATUS_REG
                        prdata <= {31'b0, pwm_done_status};    // Read PWM done status
                    end
                    default: begin
                        // Invalid read address
                        pslverr <= 1'b1;
                        prdata  <= 32'hDEADBEEF; // Indicate invalid read data
                    end
                endcase
            end
        end
    end

    // =========================================================================
    // Internal PWM Core Logic
    // This is adapted from the previous standalone PWM module.
    // =========================================================================

    // Internal 16-bit counter register for the PWM period
    reg [15:0] count;

    // Internal 16-bit counter register to track the number of completed PWM pulses
    reg [15:0] pulse_count;

    // Flag to indicate if the PWM duration has been met (used internally by PWM logic)
    reg        internal_duration_met;

    // Parameter defining the maximum value the period counter will reach.
    // For a 16-bit counter, 16'hFFFF (decimal 65535) means a full period of 65536 clock cycles.
    parameter MAX_COUNT_VALUE = 16'hFFFF;

    // Signal to detect when the main period counter wraps around (end of a PWM period)
    wire count_rollover;
    assign count_rollover = (count == MAX_COUNT_VALUE);

    // --- Counter Logic for PWM Period ---
    always @(posedge pclk or negedge preset_n) begin
        if (!preset_n || !pwm_enable_reg) begin // Reset if global reset or PWM is disabled
            count <= 16'd0;
        end else begin
            if (count_rollover) begin
                count <= 16'd0;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

    // --- Pulse Count Logic and Done Status ---
    always @(posedge pclk or negedge preset_n) begin
        if (!preset_n || !pwm_enable_reg) begin // Reset if global reset or PWM is disabled
            pulse_count <= 16'd0;
            internal_duration_met <= 1'b0;
            pwm_done_status <= 1'b0; // External status for CPU
        end else begin
            pwm_done_status <= 1'b0; // Default to not done

            if (count_rollover && !internal_duration_met && (pwm_duration_reg != 16'd0)) begin
                if (pulse_count == pwm_duration_reg - 1) begin
                    internal_duration_met <= 1'b1;
                    pulse_count <= pulse_count + 1'b1;
                    pwm_done_status <= 1'b1; // Signal completion to CPU
                end else begin
                    pulse_count <= pulse_count + 1'b1;
                end
            end else if (pwm_duration_reg == 16'd0) begin
                internal_duration_met <= 1'b1; // If duration is 0, consider it done
                pwm_done_status <= 1'b1; // Signal completion
            end
        end
    end

    // --- PWM Output Logic ---
    assign pwm_out = ((count < pwm_duty_cycle_reg) && (pwm_duty_cycle_reg != 16'd0) && !internal_duration_met && pwm_enable_reg) ? 1'b1 : 1'b0;

    // Connect internal done status to external output
    assign pwm_done = pwm_done_status;

endmodule
