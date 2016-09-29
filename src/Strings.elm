module Strings
    exposing
        ( invalidProlific
        , passwordTooShort
        , passwordsDontMatch
        )


invalidProlific : String
invalidProlific =
    "This is not a valid Prolific Academic ID"


passwordTooShort : String
passwordTooShort =
    "Password must be at least 6 characters"


passwordsDontMatch : String
passwordsDontMatch =
    "The two password don't match"
