module Explore.Msg exposing (Msg(..))

import Api
import Types


type Msg
    = TreesResult (Api.Result (Types.Page Types.Tree))
