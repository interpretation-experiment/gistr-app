module Comment.Model exposing (Model(..), initialModel)

import Form
import Types


type Model
    = Hidden
    | Showing (Form.Model Types.Comment)


initialModel : Model
initialModel =
    Hidden
