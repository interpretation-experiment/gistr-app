module Config exposing (..)


baseUrl : String
baseUrl =
    -- DEPLOYMENT
    "//127.0.0.1:8000/api"


minServerVersion : ( Int, Int, Int )
minServerVersion =
    ( 0, 11, 0 )


prolificStudyUrl : String
prolificStudyUrl =
    -- DEPLOYMENT
    "https://prolificacademic.co.uk/studies/demo"


prolificCompletionUrl : String
prolificCompletionUrl =
    -- DEPLOYMENT
    "https://prolificacademic.co.uk/submissions/551aa5c3fdf99b2c58162de9/complete?cc=COCBA68J"
