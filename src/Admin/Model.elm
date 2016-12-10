module Admin.Model
    exposing
        ( Model
        , emptyForm
        , initialModel
        )

import Form
import Types


emptyForm : Types.NewSentence
emptyForm =
    { text = ""
    , language = "english"
    , bucket = ""
    , readTimeProportion = 0
    , readTimeAllotted = 0
    , writeTimeProportion = 0
    , writeTimeAllotted = 0
    , parentId = Nothing
    }


initialModel : Model
initialModel =
    Form.empty emptyForm


type alias Model =
    Form.Model Types.NewSentence
