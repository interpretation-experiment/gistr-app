module Explore.Router
    exposing
        ( Params
        , ViewConfig
        , initialParams
        , params
        , query
        , viewConfig
        )

import Maybe.Extra exposing (unwrap, (?))


defaults : ViewConfig
defaults =
    { page = 1
    , pageSize = 10
    , rootBucket = "experiment"
    }


viewConfig : Params -> ViewConfig
viewConfig { page, pageSize, rootBucket } =
    { page = page ? defaults.page
    , pageSize = pageSize ? defaults.pageSize
    , rootBucket = rootBucket ? defaults.rootBucket
    }


params : ViewConfig -> Params
params { page, pageSize, rootBucket } =
    { page =
        if page /= defaults.page then
            Just page
        else
            Nothing
    , pageSize =
        if pageSize /= defaults.pageSize then
            Just pageSize
        else
            Nothing
    , rootBucket =
        if rootBucket /= defaults.rootBucket then
            Just rootBucket
        else
            Nothing
    }


initialParams : Params
initialParams =
    { page = Nothing
    , pageSize = Nothing
    , rootBucket = Nothing
    }


type alias ViewConfig =
    { page : Int
    , pageSize : Int
    , rootBucket : String
    }


type alias Params =
    { page : Maybe Int
    , pageSize : Maybe Int
    , rootBucket : Maybe String
    }


query : Params -> String
query { page, pageSize, rootBucket } =
    unwrap [] (\p -> [ "page=" ++ toString p ]) page
        ++ (unwrap [] (\s -> [ "page_size=" ++ toString s ]) pageSize)
        ++ (unwrap [] (\r -> [ "root_bucket=" ++ r ]) rootBucket)
        |> String.join "&"
