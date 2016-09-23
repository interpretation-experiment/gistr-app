module Decoders exposing (token, detail, user, feedback)

import Dict
import Maybe.Extra exposing ((?))
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline
import Set


-- exposing (decode, optional, required, hardcoded)

import Types


token : JD.Decoder String
token =
    JD.at [ "key" ] JD.string


detail : JD.Decoder String
detail =
    JD.at [ "detail" ] JD.string


user : JD.Decoder Types.User
user =
    Pipeline.decode Types.User
        |> Pipeline.required "id" JD.int
        |> Pipeline.required "username" JD.string
        |> Pipeline.required "is_active" JD.bool
        |> Pipeline.required "is_staff" JD.bool


feedback : Dict.Dict String String -> JD.Decoder Types.Feedback
feedback fields =
    let
        uncheckedFeedback =
            JD.dict (JD.tuple1 identity JD.string)
                |> JD.map (translateFeedback fields)
    in
        uncheckedFeedback `JD.andThen` (checkFeedback fields)


translateFeedback : Dict.Dict String String -> Types.Feedback -> Types.Feedback
translateFeedback fields feedback =
    Dict.toList feedback
        |> List.map (translateItem fields)
        |> Dict.fromList


translateItem : Dict.Dict String String -> ( String, String ) -> ( String, String )
translateItem fields ( key, value ) =
    ( (Dict.get key fields) ? key, value )


checkFeedback : Dict.Dict String String -> Types.Feedback -> JD.Decoder Types.Feedback
checkFeedback fields feedback =
    let
        isEmpty =
            Dict.keys feedback
                |> Set.fromList
                |> Set.intersect (Set.fromList (Dict.values fields))
                |> Set.isEmpty
    in
        if isEmpty then
            JD.fail "Unknown error"
        else
            JD.succeed feedback
