module Types exposing (User, Auth(..))


type alias User =
    { id : Int
    , username : String
    , isActive : Bool
    , isStaff : Bool
    }


type alias Token =
    String


type Auth
    = Anonymous
    | Authenticating
    | Authenticated Token User
