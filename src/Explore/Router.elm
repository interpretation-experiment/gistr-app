module Explore.Router
    exposing
        ( Params
        , ViewConfig
        , initialParams
        , query
        , viewConfig
        )

import Maybe.Extra exposing (unwrap, (?))


viewConfig : Params -> ViewConfig
viewConfig { page, pageSize, rootBucket } =
    { page = page ? 1
    , pageSize = pageSize ? 10
    , rootBucket = rootBucket ? "experiment"
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
