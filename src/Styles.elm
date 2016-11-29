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
    | FlexCenter
    | BtnLink
    | Btn
    | BtnPrimary
    | BtnLight
    | BtnDark
    | Avatar
    | NavIcon
    | IconSmall
    | IconBig


type CssIds
    = Page
    | Greeting


centerElement : Mixin
centerElement =
    mixin [ marginRight auto, marginLeft auto ]


linkMixin : Mixin
linkMixin =
    mixin
        [ property "transition" "color .1s"
        , color (hex "#265c83")
        , link [ color (hex "#265c83") ]
        , hover [ color (hex "#62b3d2"), textDecoration underline ]
        , active [ property "transition" "color .1s", color (hex "#007be6") ]
        , textDecoration none
        , backgroundColor unset
        , border unset
        ]


btn : Mixin
btn =
    -- TODO: deal with disabled and cursor
    mixin
        [ borderRadius (em 0.25)
        , border3 (px 1) solid (hex "#555")
        , backgroundColor (hex "#fff")
        , color (hex "#555")
        , display inlineBlock
        , marginBottom (em 0.5)
        , padding2 (em 0.5) (em 0.75)
        , textDecoration none
        , property "transition" "color 0.4s, background-color 0.4s, border 0.4s"
        ]


btnHoverFocus : Mixin
btnHoverFocus =
    mixin
        [ backgroundColor (hex "#fff")
        , color (hex "#777")
        , borderColor (hex "#ddd")
        , property "transition" "background-color 0.3s, color 0.3s, border 0.3s"
        ]


btnPrimary : Mixin
btnPrimary =
    mixin
        [ color (hex "#fff")
        , backgroundColor (hex "#0074d9")
        , borderColor unset
        ]


btnPrimaryHoverFocus : Mixin
btnPrimaryHoverFocus =
    mixin
        [ color (hex "#fff")
        , backgroundColor (hex "#0063aa")
        , borderColor (hex "#0063aa")
        ]


btnLight : Mixin
btnLight =
    mixin
        [ backgroundColor (hex "#f0f0f0")
        , borderColor (hex "#f0f0f0")
        , color (hex "#555")
        ]


btnLightHoverFocus : Mixin
btnLightHoverFocus =
    mixin
        [ backgroundColor (hex "#ddd")
        , borderColor (hex "#ddd")
        , color (hex "#444")
        ]


btnDark : Mixin
btnDark =
    mixin
        [ backgroundColor (hex "#555")
        , color (hex "#eee")
        ]


btnDarkHoverFocus : Mixin
btnDarkHoverFocus =
    mixin
        [ backgroundColor (hex "#333")
        , borderColor (hex "#333")
        , color (hex "#eee")
        ]


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
        , (.) FlexCenter [ displayFlex, alignItems center ]
        , (.) Avatar
            [ margin (px 10)
            , width (px 40)
            , height (px 40)
            , borderRadius (pct 100)
            , overflow hidden
            ]
        , (.) NavIcon
            [ display inlineBlock
            , property "fill" "#888"
            , hover [ property "fill" "#222" ]
            , margin (px 10)
            ]
        , (.) IconSmall [ width (px 20), height (px 20) ]
        , (.) IconBig [ width (px 30), height (px 30) ]
          -- COMMON ELEMENTS
        , h1 [ fontWeight normal ]
        , h2 [ fontWeight normal ]
        , h3
            [ fontWeight normal
            , fontSize (em 1.25)
            , margin3 (em 1.25) (px 0) (em 0.62)
            ]
        , p [ margin3 (px 0) (px 0) (em 0.62) ]
        , button [ fontSize (em 1) ]
        , a [ linkMixin ]
        , (.) BtnLink [ linkMixin ]
        , (.) Btn
            [ btn
            , link [ btn ]
            , hover [ btnHoverFocus ]
            , focus [ btnHoverFocus ]
            , active
                [ backgroundColor (hex "#ccc")
                , borderColor (hex "#ccc")
                , color (hex "#444")
                , property "transition" "background-color 0.3s, color 0.3s, border 0.3s"
                ]
            ]
        , (.) BtnPrimary
            [ btnPrimary
            , link [ btnPrimary ]
            , hover [ btnPrimaryHoverFocus ]
            , focus [ btnPrimaryHoverFocus ]
            , active
                [ color (hex "#fff")
                , backgroundColor (hex "#001f3f")
                , borderColor (hex "#001f3f")
                ]
            ]
        , (.) BtnLight
            [ btnLight
            , link [ btnLight ]
            , hover [ btnLightHoverFocus ]
            , focus [ btnLightHoverFocus ]
            , active
                [ backgroundColor (hex "#ccc")
                , borderColor (hex "#ccc")
                , color (hex "#444")
                ]
            ]
        , (.) BtnDark
            [ btnDark
            , link [ btnDark ]
            , hover [ btnDarkHoverFocus ]
            , focus [ btnDarkHoverFocus ]
            , active
                [ backgroundColor (hex "#777")
                , borderColor (hex "#777")
                , color (hex "#eee")
                ]
            ]
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
