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
            , fontSize (px 14)
            , fontFamilies
                [ (qt "Libre Franklin")
                , .value sansSerif
                ]
            ]
          -- GENERIC PAGE LAYOUT
        , (#) Page
            [ displayFlex
            , flexFlow1 column
            , minHeight (vh 100)
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
              -- Apply SuperNarrow/Narrow/Normal/Wide to this div
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
            , marginBottom (px 40)
            , textAlign center
            , children
                [ Css.Elements.p
                    [ fontSize (em 0.9)
                    , color (hex "#818181")
                    , marginTop (px 20)
                    , lineHeight (px 20)
                    ]
                ]
            ]
          -- UTILITIES
        , (.) Center [ centerElement ]
        , (.) CenterText [ textAlign center ]
          -- COMMON ELEMENTS
        , h1 [ fontWeight normal ]
        , h2 [ fontWeight normal ]
        , h3
            [ fontWeight normal
            , fontSize (em 1.25)
            , margin3 (em 1.25) (px 0) (em 0.62)
            ]
        , p [ margin3 (px 0) (px 0) (em 0.62) ]
          -- FONTS
        , selector "@font-face"
            [ fontFamilies [ (qt "Libre Franklin") ]
            , fontStyle normal
            , fontWeight (int 400)
            , property "src" "local('Libre Franklin'), local('LibreFranklin-Regular'), url(/assets/fonts/LibreFranklin-LatinExt-normal-400.woff2) format('woff2')"
            , property "unicode-range" "U+0100-024F, U+1E00-1EFF, U+20A0-20AB, U+20AD-20CF, U+2C60-2C7F, U+A720-A7FF"
            ]
        , selector "@font-face"
            [ fontFamilies [ (qt "Libre Franklin") ]
            , fontStyle normal
            , fontWeight (int 400)
            , property "src" "local('Libre Franklin'), local('LibreFranklin-Regular'), url(/assets/fonts/LibreFranklin-Latin-normal-400.woff2) format('woff2')"
            , property "unicode-range" "U+0000-00FF, U+0131, U+0152-0153, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2212, U+2215, U+E0FF, U+EFFD, U+F000"
            ]
        , selector "@font-face"
            [ fontFamilies [ (qt "Libre Franklin") ]
            , fontStyle normal
            , fontWeight (int 700)
            , property "src" "local('Libre Franklin Bold'), local('LibreFranklin-Bold'), url(/assets/fonts/LibreFranklin-LatinExt-normal-700.woff2) format('woff2')"
            , property "unicode-range" "U+0100-024F, U+1E00-1EFF, U+20A0-20AB, U+20AD-20CF, U+2C60-2C7F, U+A720-A7FF"
            ]
        , selector "@font-face"
            [ fontFamilies [ (qt "Libre Franklin") ]
            , fontStyle normal
            , fontWeight (int 700)
            , property "src" "local('Libre Franklin Bold'), local('LibreFranklin-Bold'), url(/assets/fonts/LibreFranklin-Latin-normal-700.woff2) format('woff2')"
            , property "unicode-range" "U+0000-00FF, U+0131, U+0152-0153, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2212, U+2215, U+E0FF, U+EFFD, U+F000"
            ]
        , selector "@font-face"
            [ fontFamilies [ (qt "Libre Franklin") ]
            , fontStyle italic
            , fontWeight (int 400)
            , property "src" "local('Libre Franklin Italic'), local('LibreFranklin-Italic'), url(/assets/fonts/LibreFranklin-LatinExt-italic-400.woff2) format('woff2')"
            , property "unicode-range" "U+0100-024F, U+1E00-1EFF, U+20A0-20AB, U+20AD-20CF, U+2C60-2C7F, U+A720-A7FF"
            ]
        , selector "@font-face"
            [ fontFamilies [ (qt "Libre Franklin") ]
            , fontStyle italic
            , fontWeight (int 400)
            , property "src" "local('Libre Franklin Italic'), local('LibreFranklin-Italic'), url(/assets/fonts/LibreFranklin-Latin-italic-400.woff2) format('woff2')"
            , property "unicode-range" "U+0000-00FF, U+0131, U+0152-0153, U+02C6, U+02DA, U+02DC, U+2000-206F, U+2074, U+20AC, U+2212, U+2215, U+E0FF, U+EFFD, U+F000"
            ]
        ]
