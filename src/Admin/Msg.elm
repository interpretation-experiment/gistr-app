module Admin.Msg exposing (Msg(..))

import Api
import Types


type Msg
    = WriteInput Types.NewSentence
    | WriteSubmit Types.NewSentence
    | WriteResult (Api.Result Types.Profile)
