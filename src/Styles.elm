module Styles exposing (css)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


css =
    (stylesheet << namespace "layout")
        [ body [ margin (px 20) ] ]
