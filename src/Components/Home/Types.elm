module Components.Home.Types exposing (..)

import Components.Home.Routes exposing (..)
import App.Routes as AppRoutes


-- MODEL


type Model
    = Empty



-- MESSAGES


type Msg
    = RequestNavigateTo AppRoutes.Route
    | RequestLogout
    | NavigateTo Route


type OutMsg
    = OutNavigateTo AppRoutes.Route
    | OutLogout


type alias TranslationDictionary t msg =
    { t | onNavigateTo : AppRoutes.Route -> msg, onLogout : msg }


type alias Translator parentMsg =
    OutMsg -> parentMsg
