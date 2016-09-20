port module Subscriptions
    exposing
        ( subscriptions
        , localTokenSet
        , localTokenGet
        , localTokenClear
        )

import Dict
import Model exposing (Model)
import Msg exposing (Msg(GotLocalToken, NoOp))
import Types


-- LOCAL STORAGE PORTS


port localStorageSet : { key : String, value : String } -> Cmd msg


port localStorageGet : String -> Cmd msg


port localStorageRemove : String -> Cmd msg


port localStorageReceive : ({ key : String, value : Maybe String } -> msg) -> Sub msg


tokenKey : String
tokenKey =
    "token"


localTokenSet : Types.Token -> Cmd msg
localTokenSet token =
    localStorageSet { key = tokenKey, value = token }


localTokenGet : Cmd msg
localTokenGet =
    localStorageGet tokenKey


localTokenClear : Cmd msg
localTokenClear =
    localStorageRemove tokenKey


localStorageMsgs : Dict.Dict String (Maybe String -> Msg)
localStorageMsgs =
    Dict.fromList [ ( tokenKey, GotLocalToken ) ]


localStorageProcess : { key : String, value : Maybe String } -> Msg
localStorageProcess { key, value } =
    let
        msg =
            Dict.get key localStorageMsgs
                |> Maybe.withDefault (always NoOp)
    in
        msg value



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    localStorageReceive localStorageProcess
