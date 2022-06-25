
mat2df(m) = DataFrame(m, [:timestamp, :open, :high, :low, :close, :volume])
# dictvec2df(dictvec) = vcat(DataFrame.(dictvec)...)

# str2float(df::DataFrame, name::String) =
#     transform(df, name => (str_value -> parse.(Float32, str_value)) => name)
# str2float(df::DataFrame, names::AbstractVector = filter(name -> name != "symbol", names(df))) =
#     foldl(str2float, names, init = df)
unixtime2datetime(df::DataFrame; name = "timestamp", div = 1000) =
    transform(df, name => (unixtime -> unix2datetime.(unixtime / div)) => name)


function draw_trade_chart(ohlcv::Matrix ; key = :close, trades_log = nothing)
    draw_trade_chart(
        unixtime2datetime(mat2df(ohlcv)),
        key = key,
        trades_log = trades_log
    )
end

function draw_trade_chart(ohlcv::DataFrame; key = :close, trades_log = nothing)
    function draw_rate(df)
        ta = TimeArray(select(df, :timestamp, key), timestamp = :timestamp)
        Plots.plot!(ta, label = "rate", color = :skyblue)
    end

    draw_trades_log(::Nothing) = nothing
    function draw_trades_log(df)
        for (order_type, color) in [("buy", :green), ("sell", :red)]
            xy = df[df.order_type .== order_type, [:timestamp, key]]
            #rates = df[df.order_type.==order_type, :rate]
            Plots.scatter!(xy.timestamp, xy[:, key], color = color, label = order_type)
        end
    end

    draw_sr_lines(::Nothing) = nothing
    function draw_sr_lines(ohlcv)
        maxima = Indicators.maxima(ohlcv.close)
        timestamps = ohlcv.timestamp[maxima]
        rates = ohlcv.close[maxima]
        Plots.scatter!(timestamps, rates, color = :red)
    
    
        minima = Indicators.minima(ohlcv.close)
        timestamps = ohlcv.timestamp[minima]
        rates = ohlcv.close[minima]
        Plots.scatter!(timestamps, rates, color = :green)
    end

    Plots.plotly()
    Plots.theme(:juno)
    Plots.plot(
        xrotation = 45,
        size = (1200, 800),
        ticks = :native
    )
    draw_rate(ohlcv)
    draw_trades_log(trades_log)
    # draw_sr_lines(ohlcv)
    return Plots.current()
end
