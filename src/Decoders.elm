module Decoders exposing (token, detail, user, email, profile, feedback)

import Date
import Dict
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline
import Maybe.Extra exposing ((?))
import Set
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
        |> Pipeline.required "profile" (Pipeline.nullable profile)
        |> Pipeline.required "emails" (JD.list email)


profile : JD.Decoder Types.Profile
profile =
    Pipeline.decode Types.Profile
        |> Pipeline.required "id" JD.int
        |> Pipeline.required "created" date
        |> Pipeline.required "prolific_id" (Pipeline.nullable JD.string)
        |> Pipeline.required "user" JD.int
        |> Pipeline.required "user_username" JD.string
        |> Pipeline.required "mothertongue" JD.string
        |> Pipeline.required "trained_reformulations" JD.bool
        |> Pipeline.required "reformulations_count" JD.int
        |> Pipeline.required "available_trees_counts" treeCounts


treeCounts : JD.Decoder Types.TreeCounts
treeCounts =
    Pipeline.decode Types.TreeCounts
        |> Pipeline.required "training" JD.int
        |> Pipeline.required "experiment" JD.int


date : JD.Decoder Date.Date
date =
    JD.string
        `JD.andThen`
            \str ->
                case Date.fromString str of
                    Err err ->
                        JD.fail err

                    Ok date ->
                        JD.succeed date


email : JD.Decoder Types.Email
email =
    Pipeline.decode Types.Email
        |> Pipeline.required "id" JD.int
        |> Pipeline.required "user" JD.int
        |> Pipeline.required "email" JD.string
        |> Pipeline.required "verified" JD.bool
        |> Pipeline.required "primary" JD.bool
        |> Pipeline.hardcoded False


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
