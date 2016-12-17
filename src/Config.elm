module Config exposing (..)


baseUrl : String
baseUrl =
    -- DEPLOYMENT
    --"//next-api.gistr.io/api"
    "//127.0.0.1:8000/api"


minServerVersion : ( Int, Int, Int )
minServerVersion =
    ( 0, 12, 0 )


prolificStudyUrl : String
prolificStudyUrl =
    -- DEPLOYMENT
    "https://prolificacademic.co.uk/studies/demo"


prolificCompletionUrl : String
prolificCompletionUrl =
    -- DEPLOYMENT
    "https://prolificacademic.co.uk/submissions/demo"
