module Experiment.Shaping
    exposing
        ( Tree(Tree)
        , fetchPossiblyShapedUntouchedTree
        , fetchRandomizedUnshapedTrees
        , selectTip
        , selectTipSentence
        , tips
        , tree
        )

import Api
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



-- SEVERAL-TREES FILTER


unshapedSeveralFilter : Int -> Types.Auth -> Filter
unshapedSeveralFilter num auth =
    (preFilter auth) ++ [ ( "sample", toString num ) ]



-- SEVERAL-TREES FETCHING TASKS


type alias Task a =
    Task.Task Types.Error a


fetchUnshapedTrees : Int -> Types.Auth -> Task (List Types.Tree)
fetchUnshapedTrees num auth =
    Api.getTrees auth Nothing (unshapedSeveralFilter num auth) |> Task.map .items


fetchRandomizedUnshapedTrees : Int -> Types.Auth -> Task (List Types.Tree)
fetchRandomizedUnshapedTrees num auth =
    Task.map2 Helpers.shuffle Helpers.seed (fetchUnshapedTrees num auth)



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


tips : Tree a -> Nonempty ( Int, Nonempty a )
tips (Tree root children) =
    case children of
        [] ->
            Nonempty.fromElement ( 0, Nonempty.fromElement root )

        head :: tail ->
            Nonempty.map maxTips (Nonempty head tail)
                |> Nonempty.map (Tuple.mapFirst ((+) 1))


maxTips : Tree a -> ( Int, Nonempty a )
maxTips (Tree root children) =
    case children of
        [] ->
            ( 0, Nonempty.fromElement root )

        head :: tail ->
            let
                childrenTips =
                    Nonempty.map maxTips (Nonempty head tail)

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
                    |> Nonempty.concat
                )


branchOrNot : Random.Seed -> Types.Auth -> Tree a -> ( Bool, Random.Seed )
branchOrNot seed auth (Tree _ children) =
    if List.length children < auth.meta.targetBranchCount then
        Random.step (Random.float 0 1) seed
            |> Tuple.mapFirst (\f -> f < auth.meta.branchProbability)
    else
        ( False, seed )


selectTip : Random.Seed -> Types.Auth -> Tree a -> a
selectTip seed auth tree =
    let
        ( branch, newSeed ) =
            branchOrNot seed auth tree
    in
        if branch then
            root tree
        else
            let
                treeTips =
                    tips tree

                unreachedTips =
                    Nonempty.toList treeTips
                        |> List.filter (\( depth, _ ) -> depth < auth.meta.targetBranchDepth)

                sampleTip eligible =
                    eligible
                        |> Nonempty.map Tuple.second
                        |> Nonempty.concat
                        |> Helpers.sample newSeed
            in
                case unreachedTips of
                    [] ->
                        if
                            ((List.length (children tree) < auth.meta.targetBranchCount)
                                && (auth.meta.branchProbability > 0)
                            )
                        then
                            root tree
                        else
                            sampleTip treeTips

                    head :: rest ->
                        sampleTip (Nonempty.Nonempty head rest)


selectTipSentence : Types.Auth -> Types.Tree -> Task Types.Sentence
selectTipSentence auth apiTree =
    let
        networkTree =
            tree apiTree.root.id apiTree.networkEdges
    in
        Task.map (\seed -> selectTip seed auth networkTree) Helpers.seed
            |> Task.andThen (Api.getSentence auth)
