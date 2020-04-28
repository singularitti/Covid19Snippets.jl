module Tracking

using DataFrames: DataFrame, groupby
using Dates: Date, @dateformat_str
using UrlDownload: urldownload

export getdata, propertybydate

const URL = "https://covidtracking.com/api/v1/states/daily.csv"

function getdata()
    df = urldownload(URL) |> DataFrame
    df.date = @. df.date |> string |> parsedate
    return sort(df, :date)
end # function getdata

parsedate(str::AbstractString) = Date(str, dateformat"yyyymmdd")

const DATA_BY_DATE = groupby(getdata(), :date)
const DATA_BY_STATE = groupby(getdata(), :state)

function propertybydate(state)
    df = DATA_BY_STATE[(state = state,)]
    return property -> zip(df.date, df[Symbol(property)])
end # function propertybydate

end # module Tracking
