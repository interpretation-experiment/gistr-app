module Components.Explore.Types exposing (..)

import Components.Explore.Routes exposing (..)


-- MODEL


type Model
    = Empty



-- MESSAGES


type Msg
    = RequestNavigateBack
    | NavigateTo Route


type OutMsg
    = OutNavigateBack


type alias TranslationDictionary t msg =
    { t | onNavigateBack : msg }


type alias Translator parentMsg =
    OutMsg -> parentMsg
