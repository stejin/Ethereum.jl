using Iterators

sequence = chain(
    [288, 256, 192, 160, 160],
    Iterators.repeated(128, 5),
    Iterators.repeated(96, 6),
    [64, 96, 96, 64, 96, 64, 64, 96],
    Iterators.repeated(64, 15),
    [32, 64, 64, 64, 32, 64, 64, 32, 64, 32, 64, 64],
    Iterators.repeated([32, 64], 6),
    Iterators.repeated([32, 32, 64], 5),
    Iterators.repeated([32, 32, 32, 64], 2),
    [32, 32, 32, 32, 64],
    Iterators.repeated(32, 6),
    [64],
    Iterators.repeated(32, 7),
    [64],
    Iterators.repeated(32)
)

extra_gas(number, seq) = number > seq

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
        c += 1
        c += max(1, floor(Int, (bytes - s) / 32)) |> (i -> Iterators.take(sequence, i)) |> Compat.Iterators.flatten |> collect |> cumsum |> (a -> extra_gas.(bytes - s, a)) |> sum
        s += 32 * 256
    end
    return c
end


using Plots

plot(rand(5,5), linewidth=2)

plot(gas_cost.(42000, linspace(32, 5000032, 100)), linewidth=2)

plot(collect(enumerate(linspace(0, 100, 10))), x=1, y=2)
