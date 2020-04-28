module Tracking

using DataFrames: DataFrame, groupby, combine, select
using Dates: Date, @dateformat_str
using UrlDownload: urldownload

export getdata, dailyproperty, allproperties

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

function dailyproperty(state)
    df = DATA_BY_STATE[(state = state,)]
    return property -> select(df, :date, Symbol(property))
end # function dailyproperty
dailyproperty() = property -> combine(Symbol(property) => sum, DATA_BY_DATE)

end # module Tracking
