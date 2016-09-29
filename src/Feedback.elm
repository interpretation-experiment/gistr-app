module Feedback
    exposing
        ( Feedback
        , empty
        , feedback
        , getError
        , getUnknown
        , globalError
        , noKnownErrors
        , updateError
        )

import Dict


type
    FeedbackItem
    -- | FeedbackSuccess <some-style-info>
    = FeedbackError String


type Feedback
    = Feedback
        { known : Dict.Dict String FeedbackItem
        , unknown : String
        }


empty : Feedback
empty =
    Feedback { known = Dict.empty, unknown = "" }


globalError : String -> Feedback
globalError value =
    customError "global" value


customError : String -> String -> Feedback
customError key error =
    updateError key (Just error) empty


updateError : String -> Maybe String -> Feedback -> Feedback
updateError key maybeValue (Feedback { known, unknown }) =
    Feedback
        { known = Dict.update key (always (Maybe.map FeedbackError maybeValue)) known
        , unknown = unknown
        }


feedback : Dict.Dict String String -> String -> Feedback
feedback errors unknown =
    Feedback
        { known = Dict.map (\k e -> FeedbackError e) errors
        , unknown = unknown
        }


isError : FeedbackItem -> Bool
isError item =
    case item of
        FeedbackError _ ->
            True


noKnownErrors : Feedback -> Bool
noKnownErrors (Feedback { known }) =
    Dict.isEmpty <| Dict.filter (\k v -> isError v) known


getUnknown : Feedback -> String
getUnknown (Feedback { unknown }) =
    unknown


getError : String -> Feedback -> String
getError key (Feedback { known }) =
    case Dict.get key known of
        Nothing ->
            ""

        Just (FeedbackError error) ->
            error
