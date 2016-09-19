module Types exposing (User, Credentials, Auth(..))


type alias User =
    { id : Int
    , username : String
    , isActive : Bool
    , isStaff : Bool
    }


type alias Credentials =
    { username : String
    , password : String
    }


type alias Token =
    String


type Auth
    = Anonymous
    | Authenticating
    | Authenticated Token User
