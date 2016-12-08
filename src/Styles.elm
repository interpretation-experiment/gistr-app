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


{-
   Credits:
   - Buttons are inspired by http://mrmrs.io/btns/
   - Tooltips are inspired by http://semantic-ui.com/modules/popup.html#tooltip
   - Inputs are inspired by http://semantic-ui.com/elements/input.html
-}


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
    | BtnIcon
    | BtnIconBtn
    | BtnLink
    | Btn
    | BtnPrimary
    | BtnWarning
    | BtnLight
    | BtnDark
    | BtnSmall
    | Avatar
    | NavIcon
    | Small
    | Big
    | Textarea
    | Input
    | Error
    | Success
    | Disabled
    | Icon
    | Left
    | Label
    | BadgeSuccess
    | BadgeDefault
    | EmailLine
    | FormInline
    | FormPage
    | FormFlex
    | FormBlock
    | Well
    | Menu
    | Active
    | InfoBox
    | RequestBox
    | Loader
    | WarningNotification
    | InfoNotification
    | SuccessNotification
    | SmoothAppearing
    | Hidden
    | Trial
    | Header
    | Clock


type CssIds
    = Page
    | Greeting
    | InputAutofocus


notification : Mixin
notification =
    mixin
        [ boxShadow4 (px 0) (px 2) (px 10) (rgba 50 50 50 0.5)
        , borderRadius (px 2)
        , margin3 (px 10) (px 10) (px 20)
        , padding (px 12)
        , minHeight (px 40)
        , opacity (num 0.8)
        , children
            [ button
                [ float right
                , marginLeft (em 0.2)
                , width (px 12)
                , height (px 12)
                , lineHeight (px 0)
                , property "visibility" "hidden"
                ]
            ]
        , hover [ children [ button [ property "visibility" "visible" ] ] ]
        ]


box : Mixin
box =
    mixin
        [ borderBottom3 (px 1) solid (rgba 214 217 221 0.5)
        , marginBottom (em 1.43)
        , borderRadius (px 2)
          -- Pad divs inside this element, since we use it in flex boxes, where
          -- layout is computed without padding (so adding padding on this
          -- element ruins the flex layout, therefore we put the padding in a
          -- child element). This is fixed by using Grid Layout, once it's in
          -- most browsers.
        , children [ div [ padding (em 0.86) ] ]
        ]


badge : Mixin
badge =
    mixin
        [ borderRadius (em 0.25)
        , color (hex "#fff")
        , fontSize (em 0.75)
        , fontWeight (int 700)
        , padding2 (em 0.2) (em 0.6)
        ]


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
        , active [ color (hex "#007be6") ]
        , textDecoration none
        , backgroundColor unset
        , border unset
        , cursor pointer
        ]


btn : Mixin
btn =
    mixin
        [ borderRadius (em 0.2)
        , border3 (px 1) solid (hex "#d6d9dd")
        , backgroundColor (hex "#f9fafb")
        , color (hex "#265c83")
        , display inlineBlock
        , padding2 (em 0.5) (em 0.75)
        , textDecoration none
        , cursor pointer
        , property
            "transition"
            "opacity 0.3s, color 0.3s, border-color 0.3s, background-color 0.3s"
        ]


btnHoverFocus : Mixin
btnHoverFocus =
    mixin [ backgroundColor (hex "#edf0f3") ]


btnPrimary : Mixin
btnPrimary =
    mixin [ color (hex "#fff"), backgroundColor (hex "#0074d9") ]


btnPrimaryHoverFocus : Mixin
btnPrimaryHoverFocus =
    mixin
        [ backgroundColor (hex "#0063aa")
        , borderColor (hex "#0063aa")
        ]


btnWarning : Mixin
btnWarning =
    mixin [ color (hex "#fff"), backgroundColor (hex "#ee930e") ]


btnWarningHoverFocus : Mixin
btnWarningHoverFocus =
    mixin
        [ backgroundColor (hex "#d78714")
        , borderColor (hex "#d78714")
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
            , padding2 (px 0) (px 10)
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
                , (.) Meta
                    [ marginLeft auto
                    , marginTop (px 10)
                    , children [ (.) Avatar [ margin2 (px 0) (px 10) ] ]
                    ]
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
        , (.) SuperNarrow [ display block, maxWidth (px 450) ]
        , (.) Narrow [ display block, maxWidth (px 540) ]
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
          -- EXPERIMENT LAYOUT
        , (.) Trial
            [ marginTop (em 2)
            , descendants
                [ (.) Header
                    [ opacity (num 0.8)
                    , displayFlex
                    , alignItems center
                    , marginBottom (em 1)
                    ]
                , (.) Clock [ marginRight (em 1), width (px 50) ]
                , selector "blockquote"
                    [ paddingLeft (em 1)
                    , borderLeft3 (px 3) solid (rgba 200 200 200 0.6)
                    , fontSize (em 1.2)
                    ]
                ]
            ]
          -- UTILITIES
        , (.) Center [ centerElement ]
        , (.) CenterText [ textAlign center ]
        , (.) FlexCenter [ displayFlex, alignItems center ]
        , (.) Avatar
            [ width (px 40)
            , height (px 40)
            , borderRadius (pct 100)
            , overflow hidden
            , opacity (num 0.7)
            , property "transition" "opacity .3s"
            , hover [ opacity (num 1) ]
            ]
        , (.) NavIcon
            [ display inlineBlock
            , property "fill" "#888"
            , property "transition" "fill .3s"
            , hover [ property "fill" "#222" ]
            , margin (px 10)
            , withClass Small [ width (px 18), height (px 18) ]
            , withClass Big [ width (px 30), height (px 30) ]
            ]
        , (.) Well
            [ minHeight (em 1)
            , padding2 (em 1) (em 2)
            , marginBottom (em 1)
            , backgroundColor (hex "#f5f5f5")
            , border3 (px 1) solid (hex "#e3e3e3")
            , borderRadius (px 2)
            , boxShadow5 inset (px 0) (px 1) (px 1) (rgba 0 0 0 0.05)
            ]
        , (.) Loader
            [ margin2 (px 0) auto
            , position relative
            , withClass Small
                [ width (em 1)
                , height (em 1)
                , margin2 (px 0) (em 1)
                , display inlineBlock
                , before [ top (em 0.2) ]
                , after [ top (em 0.2) ]
                ]
            , withClass Big
                [ width (px 30), height (px 30), marginTop (px 50) ]
            , before
                [ position absolute
                , property "content" "''"
                , borderRadius (pct 100)
                , border3 (px 2) solid (rgba 0 0 0 0.1)
                , width (pct 100)
                , height (pct 100)
                , boxSizing borderBox
                ]
            , after
                [ position absolute
                , property "content" "''"
                , property "animation" "loader .6s infinite linear"
                , borderRadius (pct 100)
                , borderColor3 (hex "#767676") transparent transparent
                , borderStyle solid
                , property "border-width" "2px"
                , boxShadow5 (px 0) (px 0) (px 0) (px 1) transparent
                , width (pct 100)
                , height (pct 100)
                , boxSizing borderBox
                ]
            ]
        , (.) WarningNotification
            [ notification
            , color (hex "#a94442")
            , backgroundColor (hex "#f2dede")
            , property "fill" "#a94442"
            ]
        , (.) InfoNotification
            [ notification
            , color (hex "#54318f")
            , backgroundColor (hex "#dfd9f7")
            , property "fill" "#54318f"
            ]
        , (.) SuccessNotification
            [ notification
            , color (hex "#389f48")
            , backgroundColor (hex "#f6fff6")
            , property "fill" "#389f48"
            ]
        , (.) SmoothAppearing
            [ property "transition" "opacity .3s ease-in-out, max-height .3s ease-in-out"
            , boxSizing borderBox
            , maxHeight (px 500)
            ]
        , (.) Hidden [ maxHeight (px 0), opacity (num 0), property "pointer-events" "none" ]
          -- COMMON ELEMENTS
        , h1 [ fontWeight normal ]
        , h2 [ fontWeight normal ]
        , h3
            [ fontWeight normal
            , fontSize (em 1.25)
            , margin3 (em 1.25) (px 0) (em 0.62)
            ]
        , h4
            [ fontWeight normal
            , fontSize (em 1.15)
            , margin2 (em 1) (px 0)
            ]
        , p [ margin3 (px 0) (px 0) (em 0.62) ]
        , button
            [ fontSize (px 14)
            , fontFamilies
                [ (qt "Libre Franklin")
                , .value sansSerif
                ]
            ]
        , ul [ margin2 (em 0.5) (em 0) ]
          -- Fix for buttons appearing differently in Chrome vs. Firefox
        , selector "button::-moz-focus-inner" [ border (px 0), padding (px 0) ]
        , a [ linkMixin ]
          -- MENU
        , (.) Menu
            [ display block
            , border3 (px 1) solid (rgba 34 36 38 0.15)
            , boxShadow5 (px 0) (px 1) (px 2) (px 0) (rgba 34 36 38 0.15)
            , marginRight (em 1)
            , backgroundColor (hex "#fcfcfc")
            , borderRadius (em 0.3)
            , children
                [ a
                    [ display block
                    , color unset
                    , padding (em 1)
                    , textDecoration none
                    , property "transition"
                        "background .1s ease, box-shadow .1s ease, color .1s ease"
                    , borderTop3 (px 1) solid (rgba 34 36 38 0.1)
                    , firstChild
                        [ borderTop (px 0)
                        , borderRadius4 (em 0.3) (em 0.3) (em 0) (em 0)
                        ]
                    , lastChild [ borderRadius4 (em 0) (em 0) (em 0.3) (em 0.3) ]
                    , active [ outline none ]
                    , hover [ backgroundColor (rgba 0 0 0 0.03) ]
                    ]
                , (.) Active
                    [ backgroundColor (rgba 0 0 0 0.07)
                    , outline none
                    , hover [ backgroundColor (rgba 0 0 0 0.07) ]
                    , firstChild [ color (hex "#006964") ]
                    ]
                ]
            ]
          -- BOXES
        , (.) RequestBox
            [ box
            , backgroundColor (hex "#fcf8e3")
            , color (hex "#8a6d3b")
            ]
        , (.) InfoBox
            [ box
            , backgroundColor (hex "#dfd9f7")
            , color (hex "#54318f")
            ]
          -- EMAIL LINE
        , (.) EmailLine
            [ displayFlex
            , alignItems baseline
            , borderBottom3 (px 1) solid (hex "#ccc")
            , marginBottom (em 0.5)
            , children
                [ (.) BtnIcon
                    [ alignSelf center
                    , property "fill" "#a00"
                    , active [ property "fill" "#f00" ]
                    , disabled [ property "fill" "#666" ]
                    ]
                , everything [ marginLeft (em 0.5), marginRight (em 0.5) ]
                , button [ firstOfType [ marginLeft auto ] ]
                ]
            ]
          -- BUTTONS
        , (.) BtnLink [ linkMixin ]
        , (.) BtnIcon
            [ border (px 0)
            , backgroundColor initial
            , padding (px 0)
            , cursor pointer
            , property "transition" "opacity 0.3s, fill 0.3s"
            , disabled
                [ cursor default
                , opacity (num 0.65)
                , property "pointer-events" "none"
                ]
            , withClass Small [ width (px 18), height (px 18) ]
            , withClass Big [ width (px 30), height (px 30) ]
            ]
        , (.) BtnIconBtn
            [ margin (em 0.2)
            , opacity (num 0.65)
            , hover [ opacity (num 1) ]
            , focus [ opacity (num 1) ]
            , active [ opacity (num 1) ]
            ]
        , (.) Btn
            [ btn
            , link [ btn ]
            , hover [ btnHoverFocus ]
            , focus [ btnHoverFocus ]
            , active
                [ backgroundColor (hex "#ccc")
                , borderColor (hex "#ccc")
                , color (hex "#444")
                ]
            , disabled
                [ cursor default
                , color (hex "#9ca0a6")
                , borderColor (hex "#c0c4cb")
                , backgroundColor (hex "#d6d9dd")
                , opacity (num 0.65)
                , property "pointer-events" "none"
                ]
            , withClass BtnPrimary
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
            , withClass BtnWarning
                [ btnWarning
                , link [ btnWarning ]
                , hover [ btnWarningHoverFocus ]
                , focus [ btnWarningHoverFocus ]
                , active
                    [ color (hex "#fff")
                    , backgroundColor (hex "#3b2404")
                    , borderColor (hex "#3b2404")
                    ]
                ]
            , withClass BtnLight
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
            , withClass BtnDark
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
            , withClass BtnSmall
                [ fontSize (em 0.8)
                , paddingTop (em 0.2)
                , paddingBottom (em 0.2)
                , margin (px 0)
                ]
            ]
          -- INPUTS
        , (.) Textarea
            [ display block
            , fontWeight normal
            , fontStyle normal
            , margin (px 0)
            , maxWidth (pct 100)
            , minHeight (em 1.29)
            , outline none
            , textAlign left
            , fontFamilies [ (qt "Libre Franklin"), .value sansSerif ]
            , fontSize (em 1)
            , padding2 (em 0.45) (em 0.85)
            , backgroundColor (hex "#fff")
            , border3 (px 1) solid (rgba 33 35 37 0.2)
            , color (rgba 0 0 0 0.87)
            , borderRadius (em 0.2)
            , property "transition" "box-shadow .1s ease, border-color .1s ease"
            , boxShadow none
            , focus [ borderColor (hex "#85b7d9"), color (rgba 0 0 0 0.8) ]
            , withClass Disabled
                [ opacity (num 0.45)
                , property "pointer-events" "none"
                , property "-webkit-user-select" "none"
                , property "-moz-user-select" "none"
                , property "-ms-user-select" "none"
                , property "user-select" "none"
                ]
            ]
        , (.) Input
            [ position relative
            , fontWeight normal
            , fontStyle normal
            , displayFlex
            , color (hex "#000000e6")
            , descendants
                [ input
                    [ margin (px 0)
                    , maxWidth (pct 100)
                    , flex2 (num 1) (num 0)
                    , flexBasis auto
                    , outline none
                    , textAlign left
                    , fontFamilies [ (qt "Libre Franklin"), .value sansSerif ]
                    , fontSize (em 1)
                    , padding2 (em 0.45) (em 0.85)
                    , backgroundColor (hex "#fff")
                    , border3 (px 1) solid (rgba 33 35 37 0.2)
                    , color (rgba 0 0 0 0.87)
                    , borderRadius (em 0.2)
                    , property "transition" "box-shadow .1s ease, border-color .1s ease"
                    , boxShadow5 inset (px 0) (px 1) (px 1) (rgba 0 0 0 0.075)
                    , disabled [ opacity (num 0.45), property "pointer-events" "none" ]
                    , focus [ borderColor (hex "#85b7d9"), color (rgba 0 0 0 0.8) ]
                    ]
                  -- Placeholder
                , selector "input::-moz-placeholder"
                    [ color (rgba 191 191 191 0.87) ]
                , selector "input::-webkit-input-placeholder"
                    [ color (rgba 191 191 191 0.87) ]
                , selector "input:-ms-input-placeholder"
                    [ color (rgba 191 191 191 0.87) ]
                  -- Placeholder focus
                , selector "input:focus::-moz-placeholder"
                    [ color (rgba 115 115 115 0.87) ]
                , selector "input:focus::-webkit-input-placeholder"
                    [ color (rgba 115 115 115 0.87) ]
                , selector "input:focus:-ms-input-placeholder"
                    [ color (rgba 115 115 115 0.87) ]
                ]
            ]
        , (.) Error
            [ color (hex "#9f3a38")
            , descendants
                [ input
                    [ borderColor (hex "#e0b4b4")
                    , backgroundColor (hex "#fff6f6")
                    , focus [ color (hex "#9f3a38"), borderColor (hex "#ce4242") ]
                    ]
                , (.) Textarea
                    [ borderColor (hex "#e0b4b4")
                    , backgroundColor (hex "#fff6f6")
                    , focus [ color (hex "#9f3a38"), borderColor (hex "#ce4242") ]
                    ]
                , (.) Label [ backgroundColor (hex "#e1bfbf") |> important ]
                  -- Placeholder
                , selector "input::-moz-placeholder" [ color (hex "#e6bcbb") ]
                , selector "input::-webkit-input-placeholder" [ color (hex "#e6bcbb") ]
                , selector "input:-ms-input-placeholder" [ color (hex "#e6bcbb") ]
                  -- Placeholder focus
                , selector "input:focus::-moz-placeholder"
                    [ color (hex "#da9796") ]
                , selector "input:focus::-webkit-input-placeholder"
                    [ color (hex "#da9796") ]
                , selector "input:focus:-ms-input-placeholder"
                    [ color (hex "#da9796") ]
                ]
            ]
        , (.) Success
            [ color (hex "#389f48")
            , descendants
                [ input
                    [ borderColor (hex "#b4e0b8")
                    , backgroundColor (hex "#f6fff6")
                    , focus [ color (hex "#389f48"), borderColor (hex "#42ce61") ]
                    ]
                , (.) Textarea
                    [ borderColor (hex "#b4e0b8")
                    , backgroundColor (hex "#f6fff6")
                    , focus [ color (hex "#389f48"), borderColor (hex "#42ce61") ]
                    ]
                , (.) Label [ backgroundColor (hex "#b8e0ba") |> important ]
                  -- Placeholder
                , selector "input::-moz-placeholder" [ color (hex "#bbe6c0") ]
                , selector "input::-webkit-input-placeholder" [ color (hex "#bbe6c0") ]
                , selector "input:-ms-input-placeholder" [ color (hex "#bbe6c0") ]
                  -- Placeholder focus
                , selector "input:focus::-moz-placeholder"
                    [ color (hex "#96da9e") ]
                , selector "input:focus::-webkit-input-placeholder"
                    [ color (hex "#96da9e") ]
                , selector "input:focus:-ms-input-placeholder"
                    [ color (hex "#96da9e") ]
                ]
            ]
          -- INPUT ICONS
        , (.) Input
            [ withClass Icon
                [ children
                    [ (.) Icon
                        [ cursor default
                        , position absolute
                        , textAlign center
                        , top (em 0.6)
                        , right (em 0.55)
                        , margin (em 0)
                        , width (em 1.2)
                        , opacity (num 0.5)
                        , borderRadius4 (em 0) (em 0.2) (em 0.2) (em 0)
                        , property "transition" "opacity .3s ease"
                        , property "pointer-events" "none"
                        ]
                    , input
                        [ paddingRight (em 2.3)
                        , focus [ generalSiblings [ (.) Icon [ opacity (num 1) ] ] ]
                        ]
                    ]
                , withClass Left
                    [ children
                        [ (.) Icon
                            [ right auto
                            , left (em 0.55)
                            , borderRadius4 (em 0.2) (em 0) (em 0) (em 0.2)
                            ]
                        , input [ paddingLeft (em 2.3), paddingRight (em 0.85) ]
                        ]
                    ]
                ]
            ]
          -- INPUT ADJACENT LABELS
        , (.) Input
            [ withClass Label
                [ children
                    [ (.) Label
                        [ flex2 (num 0) (num 0)
                        , flexBasis auto
                        , margin4 (px 0) (px -1) (px 0) (px 0)
                        , width (em 1.1)
                        , backgroundColor (hex "#d2d2d2")
                        , displayFlex
                        , flexDirection column
                        , property "justify-content" "center"
                        , padding2 (em 0) (em 0.8)
                        , property "fill" "#616469"
                        , borderRadius4 (em 0.2) (em 0) (em 0) (em 0.2)
                        , adjacentSiblings
                            [ input
                                [ borderTopLeftRadius (px 0)
                                , borderBottomLeftRadius (px 0)
                                ]
                            ]
                        ]
                    ]
                ]
            ]
          -- FORMS
        , form [ descendants [ label [ fontWeight (int 700) ] ] ]
        , (.) FormInline
            [ displayFlex
            , alignItems center
            , flexWrap wrap
            , children [ everything [ marginRight (em 1), marginBottom (em 0.5) ] ]
            , descendants [ selector "input[type=number]" [ maxWidth (em 4) ] ]
            ]
        , (.) FormPage
            [ children [ div [ marginBottom (em 1) ] ]
            , descendants
                [ (.) FormBlock
                    [ children
                        [ label [ display block ]
                        , everything [ marginBottom (em 0.5) ]
                        ]
                    ]
                ]
            ]
        , (.) FormFlex
            [ children [ div [ marginBottom (em 1) ] ]
            , descendants
                [ (.) FormBlock
                    [ displayFlex
                    , alignItems center
                    , property "justify-content" "flex-end"
                    , flexWrap wrap
                    , children
                        [ label
                            [ flex3 (num 0) (num 1) (pct 20)
                            , textAlign right
                            , marginRight (em 1)
                            ]
                        , div [ flex3 (num 0) (num 0) (pct 75) ]
                        , selector "div:not(:empty) ~ div:not(:empty)" [ marginTop (em 1) ]
                        ]
                    ]
                ]
            ]
          -- Only show number spinner on hover/focus in Firefox (mimicking
          -- Chrome default behaviour)
        , selector "input[type=number]" [ property "-moz-appearance" "textfield" ]
        , selector "input[type=number]:hover, input[type=number]:focus"
            [ property "-moz-appearance" "number-input" ]
          -- BADGES
        , (.) BadgeDefault [ badge, backgroundColor (hex "#b5b8bd") ]
        , (.) BadgeSuccess [ badge, backgroundColor (hex "#00a14b") ]
          -- TOOLTIPS
        , selector "[data-tooltip]" [ position relative ]
          -- Tooltip arrow
        , selector "[data-tooltip]:before"
            [ backgroundColor (hex "#4f5155")
            , bottom (pct 100)
            , height (em 0.5)
            , left (pct 50)
            , marginBottom (Css.rem 0.1429)
            , marginLeft (Css.rem -0.0714)
            , opacity (num 0)
            , position absolute
            , property "content" "''"
            , property "pointer-events" "none"
            , property "transform-origin" "center top"
            , property "transition" "all .1s ease"
            , property "visibility" "hidden"
            , property "z-index" "2"
            , right auto
            , top auto
            , transform (rotateZ (deg 45))
            , width (em 0.5)
            ]
          -- Tooltip content
        , selector "[data-tooltip]:after"
            [ backgroundColor (hex "#4f5155")
            , borderRadius (Css.rem 0.15)
            , borderStyle none
            , bottom (pct 100)
            , color (hex "#eff1f3")
            , fontSize (Css.rem 0.8)
            , fontStyle normal
            , fontWeight (int 400)
            , left (pct 50)
            , marginBottom (em 0.5)
            , maxWidth none
            , opacity (num 0)
            , padding2 (em 0.4) (em 0.5)
            , position absolute
            , property "content" "attr(data-tooltip)"
            , property "pointer-events" "none"
            , property "text-transform" "none"
            , property "transform-origin" "center bottom"
            , property "transition" "all .1s ease"
            , property "visibility" "hidden"
            , property "z-index" "1"
            , textAlign left
            , transform (translateX (pct -50))
            , whiteSpace noWrap
            ]
          -- Tooltip Animation
        , selector "[data-tooltip]:hover:before, [data-tooltip]:hover:after"
            [ property "visibility" "visible"
            , property "transition-delay" ".3s"
            , property "pointer-events" "auto"
            , opacity (num 1)
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
