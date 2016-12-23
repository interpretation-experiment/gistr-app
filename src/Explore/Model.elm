module Explore.Model
    exposing
        ( Model
        , initialModel
        )

import Types


initialModel : Model
initialModel =
    { trees = Nothing
    , tree = Nothing
    }


type alias Model =
    { trees : Maybe (Types.Page Types.Tree)
    , tree : Maybe TreeModel
    }


type alias TreeModel =
    { tree : Types.Tree }
