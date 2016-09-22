port module LocalStorage
    exposing
        ( subscribe
        , token
        , tokenClear
        , tokenGet
        , tokenSet
        )

import Dict
import Maybe.Extra exposing ((?))
import Types


-- PORTS


port localStorageSet : { key : String, value : String } -> Cmd msg


port localStorageGet : String -> Cmd msg


port localStorageRemove : String -> Cmd msg


port localStorageReceive : ({ key : String, value : Maybe String } -> msg) -> Sub msg



-- TOKEN


token : String
token =
    "token"


tokenSet : Types.Token -> Cmd msg
tokenSet value =
    localStorageSet { key = token, value = value }


tokenGet : Cmd msg
tokenGet =
    localStorageGet token


tokenClear : Cmd msg
tokenClear =
    localStorageRemove token



-- SUBSCRIPTIONS


subscribe : Dict.Dict String (Maybe String -> msg) -> msg -> Sub msg
subscribe tags noOp =
    let
        process { key, value } =
            value |> Dict.get key tags ? (always noOp)
    in
        localStorageReceive process
