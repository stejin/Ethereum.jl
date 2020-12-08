using Printf

include("ethereum_gas_usage_1.jl")

#startAt = 11424
#stopAt = 151808

startAt = 32
stopAt = 320000

elements = (stopAt - startAt) ÷ 32 + 1

for i in range(startAt, stop=stopAt, length=elements)
    println("$(@sprintf("%.0f", i)), $(@sprintf("%.0f", gas_usage(42646, i)))")
end
