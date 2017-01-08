module Explore.Model
    exposing
        ( Model
        , TreesModel
        , initialModel
        )

import Types


initialModel : Model
initialModel =
    { trees = Nothing
    , tree = Nothing
    }


type alias Model =
    { trees : Maybe TreesModel
    , tree : Maybe TreeModel
    }


type alias TreesModel =
    { lastTotalTrees : Int
    , maybeTrees : Maybe (List Types.Tree)
    }


type alias TreeModel =
    { tree : Types.Tree }
