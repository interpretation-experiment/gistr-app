module Main exposing (..)

import RouteUrl
import App


-- APP


main : Program Never
main =
    RouteUrl.program
        { init = App.init
        , view = App.view
        , update = App.update
        , subscriptions = App.subscriptions
        , delta2url = App.delta2url
        , location2messages = App.location2messages
        }
