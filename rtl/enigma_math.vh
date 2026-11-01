// enigma_math.vh - mod-26 arithmetic and the offset rotor pass.
// Included inside a module body AFTER enigma_tables.vh (uses rotor_fwd / rotor_inv).
// Letters are 5-bit codes A=0 .. Z=25. See docs/ENIGMA_SPEC.md for the formulas.

    // (a + b) mod 26, for a, b in 0..25
    function [4:0] add26;
        input [4:0] a;
        input [4:0] b;
        reg [5:0] s;
        begin
            s = {1'b0, a} + {1'b0, b};
            add26 = (s >= 6'd26) ? (s - 6'd26) : s[4:0];
        end
    endfunction

    // (a - b) mod 26, for a, b in 0..25
    function [4:0] sub26;
        input [4:0] a;
        input [4:0] b;
        reg [5:0] d;
        begin
            d = {1'b0, a} + 6'd26 - {1'b0, b};
            sub26 = (d >= 6'd26) ? (d - 6'd26) : d[4:0];
        end
    endfunction

    // Rotor wiring lookup for one signal. `entry` is the contact AFTER the rotor offset was added.
    //   fwd = 1: entry -> exit wiring (right-to-left) ; fwd = 0: inverse wiring (left-to-right)
    // A full rotor pass is: shift = (pos - ring) mod 26; out = (wiring[(c + shift) mod 26] - shift) mod 26.
    // enigma_core does it in two clocks: add the shift, then rotor_lookup and subtract the shift.
    function [4:0] rotor_lookup;
        input [2:0] rsel;
        input       fwd;
        input [4:0] entry;
        begin
            rotor_lookup = fwd ? rotor_fwd(rsel, entry) : rotor_inv(rsel, entry);
        end
    endfunction
