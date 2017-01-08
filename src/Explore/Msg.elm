module Explore.Msg exposing (Msg(..))

import Api
import Explore.Router
import Types


type Msg
    = TreesResult (Api.Result (Types.Page Types.Tree))
    | TreesViewConfigInput (Result String Explore.Router.ViewConfig)
