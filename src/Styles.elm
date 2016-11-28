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
    = Nav
    | NavWide
    | Meta
    | Normal
    | Wide
    | SuperNarrow
    | Narrow
    | Center
    | CenterText


type CssIds
    = Page
    | Greeting


css : Stylesheet
css =
    (stylesheet << namespace namespaceName)
        [ body
            [ margin (px 0)
            , color (hex "#616469")
            , backgroundColor (hex "#eff1f3")
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
                    [ displayFlex
                    , alignItems center
                    , minHeight (px 60)
                    ]
                , div
                    [ marginBottom (px 60)
                    , children
                        [ div
                            [ margin2 (px 0) auto
                            , displayFlex
                            ]
                        ]
                    ]
                , footer
                    [ -- CENTER
                      maxWidth (px 300)
                    , textAlign center
                      -- PUSH TO BOTTOM
                    , margin3 auto auto (px 0)
                      -- SPACE
                    , padding2 (px 10) (px 40)
                      -- LINE
                    , borderTop3 (px 1) solid (hex "#ddd")
                    ]
                ]
              -- DEBUG
              --, descendants [ everything [ border3 (px 1) solid (hex "#ccc") ] ]
            ]
        , (#) Greeting
            [ marginRight auto
            , marginLeft auto
            , marginBottom (px 30)
            , textAlign center
            , children
                [ Css.Elements.small [ fontWeight lighter ] ]
            ]
        , (.) SuperNarrow [ maxWidth (px 450) ]
        , (.) Narrow [ maxWidth (px 540) ]
        , (.) Normal [ maxWidth (px 720) ]
        , (.) Wide [ maxWidth (px 900) ]
        , (.) Nav
            [ flex3 (num 0) (num 1) (pct 10)
            , textAlign center
            ]
        , (.) NavWide [ flex3 (num 0) (num 1) (pct 20) ]
        , (.) NavWide
            [ adjacentSiblings
                [ div [ flex3 (num 0) (num 1) (pct 80) ] ]
            ]
        , (.) Meta [ marginLeft auto ]
        , (.) Center
            [ marginRight auto
            , marginLeft auto
            ]
        , (.) CenterText [ textAlign center ]
        , h1 [ marginBottom (px 10) ]
        ]
