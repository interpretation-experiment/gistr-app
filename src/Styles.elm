module Styles
    exposing
        ( CssClasses(..)
        , CssIds(..)
        , class
        , classList
        , css
        , id
        )

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)
import Html.CssHelpers


namespaceName : String
namespaceName =
    "layout"


{ id, class, classList } =
    Html.CssHelpers.withNamespace namespaceName


type CssClasses
    = -- inside Header, or inside Body
      Nav
      -- on the right, inside Header
    | Meta
      -- for body. aligns left to non-nav in header. Inside, you can have navigation (profile)
    | Normal
      -- for body. aligns left to nav in header
    | Wide
      -- for body.
    | Narrow


type CssIds
    = Page


css : Stylesheet
css =
    (stylesheet << namespace namespaceName)
        [ body
            [ margin (px 0)
            , fontFamilies
                [ (qt "HelveticaNeue-Light")
                , (qt "Helvetica Neue Light")
                , (qt "Helvetica Neue")
                , "Helvetica"
                , "Arial"
                , (qt "Lucida Grande")
                , .value sansSerif
                ]
            ]
        , (#) Page
            [ displayFlex
            , flexFlow1 column
            , minHeight (vh 100)
              -- CENTER PAGE
            , maxWidth (px 900)
            , margin2 (px 0) auto
            , children
                [ header
                    [ -- FLEX LAYOUT
                      displayFlex
                    , flexFlow1 row
                    , alignItems center
                      -- SIZE
                    , minHeight (px 100)
                    ]
                , div [ minHeight (px 200) ]
                , footer
                    [ -- CENTER
                      maxWidth (px 300)
                    , textAlign center
                      -- PUSH TO BOTTOM
                    , margin3 auto auto (px 0)
                      -- SPACE
                    , padding2 (px 10) (px 40)
                      -- LINE
                    , borderTop3 (px 1) solid (hex "#ee0000")
                    ]
                ]
              -- DEBUG
            , descendants [ everything [ border3 (px 1) solid (hex "#ccc") ] ]
            ]
        , (.) Narrow
            [ maxWidth (px 540)
            , margin2 (px 0) auto
            ]
        , (.) Meta [ marginLeft auto ]
        ]
