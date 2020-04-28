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

const DATA_BY_DATE = groupby(getdata(), :date)
const DATA_BY_STATE = groupby(getdata(), :state)

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
    property -> select(DATA_BY_STATE[(state = state,)], :date, Symbol(property))
dailyproperty() = property -> combine(Symbol(property) => sum, DATA_BY_DATE)

function _diffyesterday(data)
    df = data[2:end, :]
    df[:, 2] = diff(data[:, 2])
    return df
end # function _diffyesterday

dailyincrease(arg...) = property -> _diffyesterday(dailyproperty(arg...)(property))

function _plot(f, arg...)
    function (property)
        plotlyjs()
        data = f(arg...)(property)
        plot(data[:, 1], data[:, 2])
    end # function
end # function _plot

plotdaily(arg...) = _plot(dailyproperty, arg...)

plotincrease(arg...) = _plot(dailyincrease, arg...)

end # module Tracking
