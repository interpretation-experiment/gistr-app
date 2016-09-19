module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Router


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case (Debug.log "msg" msg) of
        NavigateTo route ->
            model
                ! if model.route /= route then
                    [ Navigation.newUrl (Router.toUrl route) ]
                  else
                    []
