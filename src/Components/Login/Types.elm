module Components.Login.Types exposing (..)

import Components.Login.Routes exposing (..)
import Services.Account.Types exposing (Credentials)


-- MODEL


type alias Model =
    { username : String
    , password : String
    }



-- MESSAGES


type Msg
    = RequestNavigateBack
    | NavigateTo Route
    | InputUsername String
    | InputPassword String
    | Login


type OutMsg
    = OutNavigateBack
    | OutLoginUser Credentials
    | OutClearLoginFeedback


type alias TranslationDictionary t msg =
    { t
        | onNavigateBack : msg
        , onLoginUser : Credentials -> msg
        , onClearLoginFeedback : msg
    }


type alias Translator parentMsg =
    OutMsg -> parentMsg
