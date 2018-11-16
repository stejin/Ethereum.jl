# Julia 1.0 implementation of Ethereum gas usage calculation

sequence = [
    [288, 256, 192, 160, 160];
    repeat([128], 5);
    repeat([96], 6);
    [64, 96, 96, 64, 96, 64, 64, 96];
    repeat([64], 15);
    [32, 64, 64, 64, 32, 64, 64, 32, 64, 32, 64, 64];
    repeat([32, 64], 6);
    repeat([32, 32, 64], 5);
    repeat([32, 32, 32, 64], 2);
    [32, 32, 32, 32, 64];
    repeat([32], 6);
    [64];
    repeat([32], 7);
    [64]
    # repeat 32 forever
]

@generated function extra_gas(start, bytes)
    ex = :()
    for (i, r) in enumerate(cumsum(sequence))
        ex = :($ex; (bytes - start) <= $r && return $i)
    end
    ex = :($ex; return floor(Int, (bytes - start - sum(sequence) - 1) / 32) + length(sequence) + 1)
end

function gas_usage(startCost, bytes)
    # Not valid for bytes less than 32
    bytes < 32 && error("Number of bytes must be greater of equal 32. Actual: $(bytes)")
    # start at gas cost for first 32 bytes
    c = startCost
    # Add 64 for each additional byte
    c += (bytes - 32) * 64
    # Add 20204 gas after each 32 bytes
    c += floor(Int, (bytes - 1) / 32) * 20204
    # Add fixed 64 gas after byte 256 except on integer multiples of 256
    bytes > 256 && bytes % 256 != 0 && (c += 64)
    # Add fixed 64 gas at byte 65792 except for the first 256 bytes every integer multiple of 65536
    bytes >= 65792 && bytes >= floor(Int, bytes / 65536) * 65536 + 256 && (c += 64)
    # Add extra gas according to sequence after byte 544
    # Start new sequence every 32 * 256 bytes
    s = 544
    while s < bytes
        c += extra_gas(s, bytes)
        s += 32 * 256
    end
    return c
end

# Usage: Obtain gas amount required by your contract for storing initial non-zero 32 bytes of data and then call gas_usage(initialGas, numberOfBytesToStore)