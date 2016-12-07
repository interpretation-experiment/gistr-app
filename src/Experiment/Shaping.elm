module Experiment.Shaping exposing (..)

import Api
import Helpers
import Lifecycle
import Maybe.Extra exposing (unwrap)
import Random
import Task
import Time
import Types


-- LANGUAGE VARIABLES


mothertongue : Types.Auth -> String
mothertongue auth =
    auth.user.profile.mothertongue


isOthertongue : Types.Auth -> Bool
isOthertongue auth =
    mothertongue auth == auth.meta.otherLanguage


rootLanguage : Types.Auth -> String
rootLanguage auth =
    if isOthertongue auth then
        auth.meta.otherLanguage
    else
        mothertongue auth



-- LANGUAGE AND BUCKET FILTER


type alias Filter =
    List ( String, String )


preFilter : Types.Auth -> Filter
preFilter auth =
    [ ( "root_language", rootLanguage auth )
    , ( "with_other_mothertongue"
      , String.toLower <| toString <| isOthertongue auth
      )
    , ( "without_other_mothertongue"
      , String.toLower <| toString <| not <| isOthertongue auth
      )
    , ( "root_bucket", Lifecycle.bucket auth.meta auth.user.profile )
    ]



-- SEVERAL-TREES FILTER


unshapedSeveralFilter : Int -> Types.Auth -> Filter
unshapedSeveralFilter num auth =
    (preFilter auth) ++ [ ( "sample", toString num ) ]



-- SEVERAL-TREES FETCHING TASKS


type alias Task a =
    Task.Task Types.Error a


fetchUnshapedTrees : Int -> Types.Auth -> Task (List Types.Tree)
fetchUnshapedTrees num auth =
    -- |> Task.map (\page -> List.map .root page.items)
    Api.getTrees auth Nothing (unshapedSeveralFilter num auth) |> Task.map .items


fetchRandomizedUnshapedTrees : Int -> Types.Auth -> Task (List Types.Tree)
fetchRandomizedUnshapedTrees num auth =
    Task.map2 Helpers.shuffle seed (fetchUnshapedTrees num auth)



-- SINGLE-TREE FILTERS


unshapedUntouchedSingleFilter : Types.Auth -> Filter
unshapedUntouchedSingleFilter auth =
    (preFilter auth)
        ++ [ ( "untouched_by_profile", toString auth.user.profile.id )
           , ( "sample", toString 1 )
           ]


shapedUntouchedSingleFilter : Types.Auth -> Filter
shapedUntouchedSingleFilter auth =
    (unshapedUntouchedSingleFilter auth)
        ++ [ ( "branches_count_lte", toString auth.meta.targetBranchCount )
           , ( "shortest_branch_depth_lte", toString auth.meta.targetBranchDepth )
           ]



-- SINGLE-TREE FETCHING TASKS


firstOr : Task Types.Tree -> Types.Page Types.Tree -> Task Types.Tree
firstOr default page =
    unwrap default Task.succeed (List.head page.items)


fetchUnshapedUntouchedTree : Types.Auth -> Task Types.Tree
fetchUnshapedUntouchedTree auth =
    Api.getTrees auth Nothing (unshapedUntouchedSingleFilter auth)
        |> Task.andThen
            (firstOr <|
                Task.fail <|
                    Types.Unrecoverable "Found no suitable tree for profile"
            )


fetchPossiblyShapedUntouchedTree : Types.Auth -> Task Types.Tree
fetchPossiblyShapedUntouchedTree auth =
    Api.getTrees auth Nothing (shapedUntouchedSingleFilter auth)
        |> Task.andThen (firstOr <| fetchUnshapedUntouchedTree auth)



-- SENTENCE-SAMPLING TASKS


type Tree a
    = Tree a (List (Tree a))


value : Tree a -> a
value (Tree a _) =
    a


children : Tree a -> List (Tree a)
children (Tree _ children) =
    children


tree : a -> List (Types.Edge a) -> Tree a
tree root edges =
    Tuple.first (treeHelp root edges)


treeHelp : a -> List (Types.Edge a) -> ( Tree a, List (Types.Edge a) )
treeHelp root edges =
    case List.partition (\e -> e.source == root) edges of
        ( [], otherEdges ) ->
            ( Tree root [], otherEdges )

        ( rootEdges, otherEdges ) ->
            let
                targets =
                    List.map .target rootEdges

                consSubTree target ( currentSubTrees, currentRemEdges ) =
                    let
                        ( subTree, newRemEdges ) =
                            treeHelp target currentRemEdges
                    in
                        ( subTree :: currentSubTrees, newRemEdges )

                ( subTrees, remEdges ) =
                    List.foldl consSubTree ( [], otherEdges ) targets
            in
                ( Tree root subTrees, remEdges )



--tips : Tree a -> List ( Int, List a )
--selectTip : Types.Auth -> Random.Seed -> Tree a -> a
--selectSentence : Types.Auth -> Types.Tree -> Task Types.Sentence
-- RANDOM TASKS


seed : Task Random.Seed
seed =
    Task.map (Random.initialSeed << round << Time.inMilliseconds) Time.now



-- LOADING AND PRELOADING HELPERS


selectPreloaded : List a -> Result Types.Error ( List a, a )
selectPreloaded preLoaded =
    case preLoaded of
        [] ->
            Err <| Types.Unrecoverable "No preloaded trees to select from"

        head :: rest ->
            Ok ( rest, head )
