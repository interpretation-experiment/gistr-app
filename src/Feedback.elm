module Feedback
    exposing
        ( Feedback
        , animate
        , empty
        , feedback
        , fromValidator
        , getError
        , getSuccess
        , getUnknown
        , globalError
        , globalSuccess
        , hasError
        , hasSuccess
        , isEmpty
        , noKnownErrors
        , successAnimations
        , updateError
        )

import Animation
import Dict
import Time
import Validate


type FeedbackItem
    = FeedbackError String
    | FeedbackSuccess Animation.State


type Feedback
    = Feedback
        { known : Dict.Dict String FeedbackItem
        , unknown : String
        }



-- CREATING


feedback : Dict.Dict String String -> String -> Feedback
feedback errors unknown =
    Feedback
        { known = Dict.map (\k e -> FeedbackError e) errors
        , unknown = unknown
        }


empty : Feedback
empty =
    feedback Dict.empty ""


globalError : String -> Feedback
globalError value =
    customError "global" value


customError : String -> String -> Feedback
customError key error =
    updateError key (Just error) empty


globalSuccess : Feedback -> Feedback
globalSuccess currentFeedback =
    customSuccess "global" currentFeedback


customSuccess : String -> Feedback -> Feedback
customSuccess key currentFeedback =
    setSuccess key currentFeedback empty


fromValidator : a -> Validate.Validator ( String, String ) a -> Feedback
fromValidator subject validator =
    feedback (validator subject |> Dict.fromList) ""



-- UPDATING


updateError : String -> Maybe String -> Feedback -> Feedback
updateError key maybeValue (Feedback { known, unknown }) =
    Feedback
        { known = Dict.update key (always (Maybe.map FeedbackError maybeValue)) known
        , unknown = unknown
        }


setSuccess : String -> Feedback -> Feedback -> Feedback
setSuccess key currentFeedback (Feedback { known, unknown }) =
    let
        success =
            startSuccessAnimation (getSuccess key currentFeedback)
    in
        Feedback
            { known = Dict.insert key (FeedbackSuccess success) known
            , unknown = unknown
            }



-- ANIMATING


startSuccessAnimation : Animation.State -> Animation.State
startSuccessAnimation =
    Animation.interrupt
        [ Animation.set [ Animation.display Animation.inline ]
        , Animation.wait (2 * Time.second)
        , Animation.set [ Animation.display Animation.none ]
        ]


animate : Animation.Msg -> Feedback -> Feedback
animate msg (Feedback { known, unknown }) =
    Feedback
        { known = Dict.map (\k v -> mapSuccess (Animation.update msg) v) known
        , unknown = unknown
        }


mapSuccess : (Animation.State -> Animation.State) -> FeedbackItem -> FeedbackItem
mapSuccess func item =
    case item of
        FeedbackError _ ->
            item

        FeedbackSuccess success ->
            FeedbackSuccess (func success)


successValue : FeedbackItem -> Maybe Animation.State
successValue item =
    case item of
        FeedbackError _ ->
            Nothing

        FeedbackSuccess success ->
            Just success


successAnimations : Feedback -> List Animation.State
successAnimations (Feedback { known, unknown }) =
    known
        |> Dict.values
        |> List.filterMap successValue



-- ACCESSING


isError : FeedbackItem -> Bool
isError item =
    case item of
        FeedbackError _ ->
            True

        FeedbackSuccess _ ->
            False


isEmpty : Feedback -> Bool
isEmpty feedback =
    feedback == empty


noKnownErrors : Feedback -> Bool
noKnownErrors (Feedback { known }) =
    Dict.isEmpty <| Dict.filter (\k v -> isError v) known


getUnknown : Feedback -> String
getUnknown (Feedback { unknown }) =
    unknown


hasError : String -> Feedback -> Bool
hasError key (Feedback { known }) =
    case Dict.get key known of
        Just (FeedbackError error) ->
            True

        Just (FeedbackSuccess _) ->
            False

        Nothing ->
            False


getError : String -> Feedback -> String
getError key (Feedback { known }) =
    case Dict.get key known of
        Just (FeedbackError error) ->
            error

        Just (FeedbackSuccess _) ->
            ""

        Nothing ->
            ""


hasSuccess : String -> Feedback -> Bool
hasSuccess key (Feedback { known }) =
    case Dict.get key known of
        Just (FeedbackSuccess success) ->
            True

        Just (FeedbackError _) ->
            False

        Nothing ->
            False


getSuccess : String -> Feedback -> Animation.State
getSuccess key (Feedback { known }) =
    case Dict.get key known of
        Just (FeedbackSuccess success) ->
            success

        Just (FeedbackError _) ->
            Animation.style [ Animation.display Animation.none ]

        Nothing ->
            Animation.style [ Animation.display Animation.none ]