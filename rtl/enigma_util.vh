// enigma_util.vh - small constant helpers. Included inside a module body, before first use.

    // Number of bits needed to count 0 .. value-1 (at least 1). Constant function, usable in localparams.
    function integer clog2;
        input integer value;
        integer v;
        begin
            v = value - 1;
            clog2 = 0;
            while (v > 0) begin
                clog2 = clog2 + 1;
                v = v >> 1;
            end
            if (clog2 == 0) clog2 = 1;
        end
    endfunction
