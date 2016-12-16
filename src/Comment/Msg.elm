module Comment.Msg exposing (Msg(..))

import Api
import Types


type Msg
    = Hide
    | Show
    | Toggle
    | CommentInput Types.Comment
    | CommentSubmit Types.Comment
    | CommentResult (Api.Result Types.Profile)
