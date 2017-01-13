module Experiment.Shaping
    exposing
        ( Tree(Tree)
        , branchTips
        , fetchPossiblyShapedUntouchedTree
        , fetchUnshapedUntouchedTree
        , selectTip
        , selectTipSentence
        , tree
        )

import Api
import Array
import Helpers
import Helpers
import Lifecycle
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty(Nonempty))
import Maybe.Extra exposing (unwrap)
import Random
import Task
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



-- PROFILE AND SHAPING FILTERS


unshapedUntouchedFilter : Types.Auth -> Filter
unshapedUntouchedFilter auth =
    (preFilter auth) ++ [ ( "untouched_by_profile", toString auth.user.profile.id ) ]


shapedUntouchedFilter : Types.Auth -> Filter
shapedUntouchedFilter auth =
    (unshapedUntouchedFilter auth)
        ++ [ ( "branches_count_lte", toString auth.meta.targetBranchCount )
           , ( "shortest_branch_depth_lte", toString auth.meta.targetBranchDepth )
           ]



-- SINGLE-TREE FETCHING TASKS


type alias Task a =
    Task.Task Types.Error a


justOr : Task Types.Tree -> Maybe Types.Tree -> Task Types.Tree
justOr default maybeTree =
    unwrap default Task.succeed maybeTree


fetchUnshapedUntouchedTree : Types.Auth -> Task Types.Tree
fetchUnshapedUntouchedTree auth =
    Api.getFreeTree auth (unshapedUntouchedFilter auth)
        |> Task.andThen
            (justOr <|
                Task.fail <|
                    Types.Unrecoverable "Found no suitable tree for profile"
            )


fetchPossiblyShapedUntouchedTree : Types.Auth -> Task Types.Tree
fetchPossiblyShapedUntouchedTree auth =
    Api.getFreeTree auth (shapedUntouchedFilter auth)
        |> Task.andThen (justOr <| fetchUnshapedUntouchedTree auth)



-- SENTENCE-SAMPLING TASKS


type Tree a
    = Tree a (List (Tree a))


root : Tree a -> a
root (Tree r _) =
    r


children : Tree a -> List (Tree a)
children (Tree _ c) =
    c


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


branchTips : Tree comparable -> Nonempty ( comparable, Int, comparable )
branchTips (Tree treeRoot children) =
    case children of
        [] ->
            Nonempty.fromElement ( treeRoot, 0, treeRoot )

        head :: tail ->
            let
                branchMaxTip subTree =
                    let
                        ( depth, tip ) =
                            maxTip subTree
                    in
                        ( root subTree, depth + 1, tip )
            in
                Nonempty.map branchMaxTip (Nonempty head tail)


maxTip : Tree comparable -> ( Int, comparable )
maxTip (Tree root children) =
    case children of
        [] ->
            ( 0, root )

        head :: tail ->
            let
                childrenTips =
                    Nonempty.map maxTip (Nonempty head tail)

                maxDepth =
                    Nonempty.map Tuple.first childrenTips
                        |> Helpers.nonemptyMaximum
            in
                ( maxDepth + 1
                , Nonempty.filter
                    (\( depth, _ ) -> depth == maxDepth)
                    (Nonempty.head childrenTips)
                    childrenTips
                    |> Nonempty.map Tuple.second
                    |> Helpers.nonemptyMinimum
                )


branchOrNot : Random.Seed -> Types.Auth -> Tree a -> ( Bool, Random.Seed )
branchOrNot seed auth (Tree _ children) =
    if List.length children < auth.meta.targetBranchCount then
        Random.step (Random.float 0 1) seed
            |> Tuple.mapFirst (\f -> f < auth.meta.branchProbability)
    else
        ( False, seed )


selectTip : Random.Seed -> Types.Auth -> Tree comparable -> comparable
selectTip seed auth tree =
    let
        ( branch, newSeed ) =
            branchOrNot seed auth tree
    in
        if branch then
            root tree
        else
            let
                orderedBranchTips =
                    branchTips tree
                        |> Nonempty.sortBy (\( branch, _, _ ) -> branch)

                eligibleBranchTips =
                    if auth.meta.targetBranchCount == 0 then
                        orderedBranchTips
                    else
                        Nonempty.tail orderedBranchTips
                            |> Array.fromList
                            |> Array.slice 0 (auth.meta.targetBranchCount - 1)
                            |> Array.toList
                            |> Nonempty (Nonempty.head orderedBranchTips)

                depthUnreachedBranchTips =
                    eligibleBranchTips
                        |> Nonempty.toList
                        |> List.filter (\( _, depth, _ ) -> depth < auth.meta.targetBranchDepth)

                sampleTip eligible =
                    eligible
                        |> Nonempty.map (\( _, _, tip ) -> tip)
                        |> Helpers.sample newSeed
            in
                case depthUnreachedBranchTips of
                    [] ->
                        if
                            ((List.length (children tree) < auth.meta.targetBranchCount)
                                && (auth.meta.branchProbability > 0)
                            )
                        then
                            root tree
                        else
                            sampleTip eligibleBranchTips

                    head :: rest ->
                        sampleTip (Nonempty head rest)


selectTipSentence : Types.Auth -> Types.Tree -> Task Types.Sentence
selectTipSentence auth apiTree =
    let
        networkTree =
            tree apiTree.root.id apiTree.networkEdges
    in
        Task.map (\seed -> selectTip seed auth networkTree) Helpers.seed
            |> Task.andThen (Api.getSentence auth)
