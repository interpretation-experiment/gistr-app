module Explore.View.Trees exposing (view)

import Explore.Model exposing (TreesModel)
import Explore.Msg exposing (Msg(..))
import Explore.Router exposing (ViewConfig, params)
import Helpers
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Msg as AppMsg
import Router
import Styles exposing (class, classList, id)
import Types


view :
    (Msg -> AppMsg.Msg)
    -> Maybe TreesModel
    -> Types.Auth
    -> ViewConfig
    -> List (Html.Html AppMsg.Msg)
view lift maybeModel auth config =
    [ Html.header [] header
    , Html.main_ []
        [ Html.div [ class [ Styles.Narrow ] ]
            (body lift maybeModel auth config)
        ]
    ]


header : List (Html.Html AppMsg.Msg)
header =
    [ Html.nav [] [ Helpers.navIcon [ class [ Styles.Big ] ] Router.Home "home" ]
    , Html.h1 [] [ Html.text "Explore Trees" ]
    ]


body :
    (Msg -> AppMsg.Msg)
    -> Maybe TreesModel
    -> Types.Auth
    -> ViewConfig
    -> List (Html.Html AppMsg.Msg)
body lift maybeModel auth config =
    case maybeModel of
        Nothing ->
            [ Helpers.loading Styles.Big ]

        Just { lastTotalTrees, maybeTrees } ->
            [ controls lift auth.meta config lastTotalTrees (maybeTrees == Nothing)
            , treesView maybeTrees
            ]


controls :
    (Msg -> AppMsg.Msg)
    -> Types.Meta
    -> ViewConfig
    -> Int
    -> Bool
    -> Html.Html AppMsg.Msg
controls lift meta config totalTrees loading =
    let
        pageCount =
            ceiling <| (toFloat totalTrees) / (toFloat config.pageSize)

        button n =
            Html.button
                [ class [ Styles.Btn ]
                , Attributes.disabled <| (n == config.page) || loading
                , Events.onClick <| lift <| TreesViewConfigInput <| Ok { config | page = n }
                ]
                [ Html.text <| toString n ]

        pageSizeOption size =
            Html.option
                [ Attributes.value (toString size)
                , Attributes.selected (config.pageSize == size)
                ]
                [ Html.text (toString size) ]

        bucketOption bucket =
            Html.option
                [ Attributes.value bucket.name
                , Attributes.selected (config.rootBucket == bucket.name)
                ]
                [ Html.text bucket.label ]
    in
        Html.div []
            [ Html.div []
                (List.map button <| List.range 1 pageCount)
            , Html.div []
                [ Html.select
                    [ Attributes.id "inputPageSize"
                    , Attributes.disabled loading
                    , Helpers.onChange <|
                        lift
                            << TreesViewConfigInput
                            << Result.map (\s -> { config | pageSize = s, page = 1 })
                            << String.toInt
                    ]
                    (List.map pageSizeOption [ 5, 10, 25, 50, 100 ])
                , Html.label [ Attributes.for "inputPageSize" ]
                    [ Html.text "Trees per page" ]
                ]
            , Html.div []
                [ Html.select
                    [ Attributes.id "inputRootBucket"
                    , Attributes.disabled loading
                    , Helpers.onChange <|
                        lift
                            << TreesViewConfigInput
                            << \r -> Ok { config | rootBucket = r, page = 1 }
                    ]
                    (List.map bucketOption meta.bucketChoices)
                , Html.label [ Attributes.for "inputRootBucket" ]
                    [ Html.text "Trees" ]
                ]
            ]


treesView : Maybe (List Types.Tree) -> Html.Html AppMsg.Msg
treesView maybeTrees =
    case maybeTrees of
        Nothing ->
            Helpers.loading Styles.Big

        Just trees ->
            Html.div [] <| List.map treeView trees


treeView : Types.Tree -> Html.Html AppMsg.Msg
treeView tree =
    Html.div [] [ Html.text tree.root.text ]
