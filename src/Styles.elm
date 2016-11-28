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
    = Meta
    | SuperNarrow
    | Narrow
    | Normal
    | Wide
    | Center
    | CenterText


type CssIds
    = Page
    | Greeting


centerElement : Mixin
centerElement =
    mixin [ marginRight auto, marginLeft auto ]


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
          -- GENERIC PAGE LAYOUT
        , (#) Page
            [ displayFlex
            , flexFlow1 column
            , minHeight (vh 100)
              -- CENTER PAGE
            , maxWidth (px 900)
            , centerElement
            ]
        , header
            [ displayFlex
            , alignItems center
            , minHeight (px 60)
            , children
                [ nav [ flex3 (num 0) (num 1) (pct 10), textAlign center ]
                , (.) Meta [ marginLeft auto ]
                ]
            ]
        , main_
            [ marginBottom (px 60)
            , children [ div [ centerElement, displayFlex ] ]
            , descendants
                [ nav
                    [ flex3 (num 0) (num 1) (pct 20)
                    , adjacentSiblings [ div [ flex3 (num 0) (num 1) (pct 80) ] ]
                    ]
                ]
            ]
        , footer
            [ maxWidth (px 300)
            , textAlign center
            , marginTop auto
            , centerElement
            , padding2 (px 10) (px 40)
            , borderTop3 (px 1) solid (hex "#ddd")
            ]
          -- BODY SIZING
        , (.) SuperNarrow [ maxWidth (px 450) ]
        , (.) Narrow [ maxWidth (px 540) ]
        , (.) Normal [ maxWidth (px 720) ]
        , (.) Wide [ maxWidth (px 900) ]
          -- HOME LAYOUT
        , (#) Greeting
            [ centerElement
            , marginBottom (px 30)
            , textAlign center
            , children [ Css.Elements.small [ fontWeight lighter ] ]
            ]
          -- UTILITIES
        , (.) Center [ centerElement ]
        , (.) CenterText [ textAlign center ]
        , h1 [ marginBottom (px 10) ]
        ]
