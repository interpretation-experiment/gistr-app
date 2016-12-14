module Feedback
    exposing
        ( Feedback
        , empty
        , feedback
        , fromValidator
        , getError
        , getSuccess
        , getUnknown
        , globalError
        , hasError
        , hasSuccess
        , isEmpty
        , noKnownErrors
        , setGlobalSuccess
        , updateError
        )

import Dict
import Validate


type Item
    = Error String
    | Success String


type Feedback
    = Feedback
        { known : Dict.Dict String Item
        , unknown : String
        }



-- CREATING


feedback : Dict.Dict String String -> String -> Feedback
feedback errors unknown =
    Feedback
        { known = Dict.map (\k e -> Error e) errors
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
    Feedback
        { known = Dict.fromList [ ( key, Error error ) ]
        , unknown = ""
        }


setGlobalSuccess : String -> Feedback -> Feedback
setGlobalSuccess value currentFeedback =
    setCustomSuccess "global" value currentFeedback


setCustomSuccess : String -> String -> Feedback -> Feedback
setCustomSuccess key value (Feedback { known, unknown }) =
    Feedback
        { known = Dict.insert key (Success value) known
        , unknown = unknown
        }


fromValidator : a -> Validate.Validator ( String, String ) a -> Feedback
fromValidator subject validator =
    feedback (validator subject |> Dict.fromList) ""



-- UPDATING


updateError : String -> Maybe String -> Feedback -> Feedback
updateError key maybeValue (Feedback { known, unknown }) =
    Feedback
        { known = Dict.update key (always (Maybe.map Error maybeValue)) known
        , unknown = unknown
        }



-- ACCESSING


isError : Item -> Bool
isError item =
    case item of
        Error _ ->
            True

        Success _ ->
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
        Just (Error _) ->
            True

        Just (Success _) ->
            False

        Nothing ->
            False


getError : String -> Feedback -> String
getError key (Feedback { known }) =
    case Dict.get key known of
        Just (Error error) ->
            error

        Just (Success _) ->
            ""

        Nothing ->
            ""


hasSuccess : String -> Feedback -> Bool
hasSuccess key (Feedback { known }) =
    case Dict.get key known of
        Just (Success _) ->
            True

        Just (Error _) ->
            False

        Nothing ->
            False


getSuccess : String -> Feedback -> String
getSuccess key (Feedback { known }) =
    case Dict.get key known of
        Just (Success success) ->
            success

        Just (Error _) ->
            ""

        Nothing ->
            ""
