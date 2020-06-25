module Tracking

using DataFrames: DataFrame, groupby, combine, select
using Dates: Date, @dateformat_str
using Plots
using UrlDownload: urldownload

export getdata, dailyproperty, allproperties, dailyincrease, plotdaily, plotincrease

const URL = "https://covidtracking.com/api/v1/states/daily.csv"

function getdata()
    df = urldownload(URL) |> DataFrame
    df.date = @. df.date |> string |> parsedate
    return sort(df, :date)
end # function getdata

parsedate(str::AbstractString) = Date(str, dateformat"yyyymmdd")

allproperties() = (
    :positive,
    :negative,
    :pending,
    :hospitalizedCurrently,
    :hospitalizedCumulative,
    :inIcuCurrently,
    :inIcuCumulative,
    :onVentilatorCurrently,
    :onVentilatorCumulative,
    :recovered,
    :hash,
    :dateChecked,
    :death,
    :hospitalized,
    :total,
    :totalTestResults,
    :posNeg,
    :fips,
    :deathIncrease,
    :hospitalizedIncrease,
    :negativeIncrease,
    :positiveIncrease,
    :totalTestResultsIncrease,
)

dailyproperty(state) =
    property -> select(groupby(getdata(), :state)[(state = state,)], :date, Symbol(property))
dailyproperty() = property -> combine(Symbol(property) => sum, groupby(getdata(), :date))

function _diffyesterday(data)
    df = data[2:end, :]
    df[:, 2] = diff(data[:, 2])
    return df
end # function _diffyesterday

dailyincrease(arg...) = property -> _diffyesterday(dailyproperty(arg...)(property))

function _plot(f, args...)
    function (property)
        plotlyjs()
        data = f(args...)(property)
        plot(data[:, 1], data[:, 2])
    end # function
end # function _plot

plotdaily(args...) = _plot(dailyproperty, args...)

plotincrease(args...) = _plot(dailyincrease, args...)

end # module Tracking
