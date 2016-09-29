module Decoders exposing (token, detail, user, email, profile, feedback)

import Date
import Dict
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline
import Maybe.Extra exposing ((?))
import Types
import Feedback


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


feedback : Dict.Dict String String -> JD.Decoder Feedback.Feedback
feedback fields =
    (JD.dict (JD.tuple1 identity JD.string) |> JD.map (toFeedback fields))
        `JD.andThen`
            \feedback ->
                if Feedback.noKnownErrors feedback then
                    JD.fail ("Unknown errors: " ++ (Feedback.getUnknown feedback))
                else
                    JD.succeed feedback


toFeedback : Dict.Dict String String -> Dict.Dict String String -> Feedback.Feedback
toFeedback fields feedbackItems =
    let
        ( known, unknown ) =
            Dict.partition (\k v -> Dict.member k fields) feedbackItems

        finishFeedback processed =
            Feedback.feedback processed (toString unknown)
    in
        Dict.toList known
            |> List.map (\( k, e ) -> ( (Dict.get k fields) ? k, e ))
            |> Dict.fromList
            |> finishFeedback
