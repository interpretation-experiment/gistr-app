module Config exposing (..)


baseUrl : String
baseUrl =
    -- Set through Makefile according to config/<target>.json
    "{{config-baseUrl}}"


minServerVersion : ( Int, Int, Int )
minServerVersion =
    ( 0, 13, 1 )


prolificStudyUrl : String
prolificStudyUrl =
    -- Set through Makefile according to config/<target>.json
    "{{config-prolificStudyUrl}}"


prolificCompletionUrl : String
prolificCompletionUrl =
    -- Set through Makefile according to config/<target>.json
    "{{config-prolificCompletionUrl}}"


expDuration : String
expDuration =
    -- Set through Makefile according to config/<target>.json
    "{{config-expDuration}}"
