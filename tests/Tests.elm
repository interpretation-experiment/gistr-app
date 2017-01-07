module Tests exposing (..)

import Expect
import Experiment.Shaping
import Fixtures
import Fuzz exposing (list, int, tuple, string)
import Helpers
import List.Nonempty as Nonempty
import List.Nonempty exposing (Nonempty(Nonempty))
import Random
import String
import Test exposing (..)


all : Test
all =
    describe "Gistr Test Suite"
        [ describe "Experiment.Shaping"
            [ tree
            , tips
            , selectTip
            ]
        , describe "Helpers"
            [ sample
            , nonemptyMaximum
            , nonemptyMinimum
            ]
        ]



-- Experiment.Shaping


tree : Test
tree =
    let
        input =
            [ { source = 1, target = 11 }
            , { source = 1, target = 12 }
            , { source = 1, target = 13 }
            , { source = 11, target = 111 }
            , { source = 11, target = 112 }
            , { source = 12, target = 121 }
              -- Different component
            , { source = 2, target = 21 }
            ]

        output1 =
            Experiment.Shaping.Tree 1
                [ Experiment.Shaping.Tree 13 []
                , Experiment.Shaping.Tree 12
                    [ Experiment.Shaping.Tree 121 []
                    ]
                , Experiment.Shaping.Tree 11
                    [ Experiment.Shaping.Tree 112 []
                    , Experiment.Shaping.Tree 111 []
                    ]
                ]

        output11 =
            Experiment.Shaping.Tree 11
                [ Experiment.Shaping.Tree 112 []
                , Experiment.Shaping.Tree 111 []
                ]

        output2 =
            Experiment.Shaping.Tree 2 [ Experiment.Shaping.Tree 21 [] ]

        output3 =
            Experiment.Shaping.Tree 3 []
    in
        describe "build tree"
            [ test "builds a tree given its root, ignoring unconnected components" <|
                \_ ->
                    Experiment.Shaping.tree 1 input
                        |> Expect.equal output1
            , test "builds a different tree given another root" <|
                \_ ->
                    Experiment.Shaping.tree 11 input
                        |> Expect.equal output11
            , test "builds a different component if the root is in another component" <|
                \_ ->
                    Experiment.Shaping.tree 2 input
                        |> Expect.equal output2
            , test "builds an empty tree if no edges are found for the given root" <|
                \_ ->
                    Experiment.Shaping.tree 3 input
                        |> Expect.equal output3
            ]


tips : Test
tips =
    let
        input =
            Experiment.Shaping.Tree 1
                [ Experiment.Shaping.Tree 11
                    [ Experiment.Shaping.Tree 111
                        [ Experiment.Shaping.Tree 1111 []
                        , Experiment.Shaping.Tree 1112 []
                        ]
                    , Experiment.Shaping.Tree 112 []
                    ]
                , Experiment.Shaping.Tree 12
                    [ Experiment.Shaping.Tree 121 []
                    ]
                , Experiment.Shaping.Tree 13 []
                ]

        output =
            Nonempty ( 3, Nonempty 1111 [ 1112 ] )
                [ ( 2, Nonempty.fromElement 121 )
                , ( 1, Nonempty.fromElement 13 )
                ]
    in
        describe "tree tips"
            [ test "finds tips and their depth in a given tree" <|
                \_ ->
                    Experiment.Shaping.tips input
                        |> Expect.equal output
            , test "finds a single tip in a tree with a root and no leaves" <|
                \_ ->
                    Experiment.Shaping.tips (Experiment.Shaping.Tree 2 [])
                        |> Expect.equal (Nonempty.fromElement ( 0, Nonempty.fromElement 2 ))
            ]


selectTip : Test
selectTip =
    let
        {-
           1 ── 11 ── 111 ── 1111 ── 11111   <-- can be selected if targetBranchDepth <= 3
           │    │                                                or targetBranchDepth >= 5
           │    └──── 112                    <-- never selected
           │
           ├─── 12 ── 121 ── 1211            <-- can be selected
           │    │
           │    └──── 122                    <-- never selected
           │
           └─── 13 ── 131 ── 1311            <-- can be selected
                      │
                      └───── 1312            <-- can be selected

           - basics

             - always returns the root on a tree with no children
             - returns either the root (== branching), or one of the deepest tips of
                 one of the sub-trees < targetDepth, if any,
                 any sub-tree, otherwise
             - never branches when targetBranchCount is reached
             - always branches if targetBranchDepth is reached on all branches, but not targetBranchCount

           - effects of branchProbability

             - never branches when branchProbability is 0
             - always branches when branchProbability is 1 and targetBranchCount is not reached

        -}
        input =
            Experiment.Shaping.Tree 1
                [ Experiment.Shaping.Tree 11
                    [ Experiment.Shaping.Tree 111
                        [ Experiment.Shaping.Tree 1111
                            [ Experiment.Shaping.Tree 11111 []
                            ]
                        ]
                    , Experiment.Shaping.Tree 112 []
                    ]
                , Experiment.Shaping.Tree 12
                    [ Experiment.Shaping.Tree 121
                        [ Experiment.Shaping.Tree 1211 []
                        ]
                    , Experiment.Shaping.Tree 122 []
                    ]
                , Experiment.Shaping.Tree 13
                    [ Experiment.Shaping.Tree 131
                        [ Experiment.Shaping.Tree 1311 []
                        , Experiment.Shaping.Tree 1312 []
                        ]
                    ]
                ]

        (Experiment.Shaping.Tree inputRoot inputChildren) =
            input

        eligibleTipsWithTargetDepth4 =
            [ 1211, 1311, 1312 ]

        eligibleTipsWithTargetDepthNot4 =
            [ 11111, 1211, 1311, 1312 ]

        setBranchProbability p auth =
            let
                meta =
                    auth.meta

                newMeta =
                    { meta | branchProbability = p }
            in
                { auth | meta = newMeta }
    in
        describe "select tip"
            [ describe "shaping requirements"
                [ fuzz2 int Fixtures.auth "always returns the root on a tree with no children" <|
                    \seeder auth ->
                        Experiment.Shaping.selectTip (Random.initialSeed seeder)
                            auth
                            (Experiment.Shaping.Tree inputRoot [])
                            |> Expect.equal inputRoot
                , fuzz2 int Fixtures.auth "returns the root or one of (tips < targetBranchDepth) or any tip if there are none of the first" <|
                    \seeder auth ->
                        let
                            eligibleTips =
                                if auth.meta.targetBranchDepth == 4 then
                                    eligibleTipsWithTargetDepth4
                                else
                                    eligibleTipsWithTargetDepthNot4
                        in
                            Experiment.Shaping.selectTip (Random.initialSeed seeder) auth input
                                |> (\t -> (t == inputRoot) || (List.member t eligibleTips))
                                |> Expect.true "Expected root or an eligible tip"
                , fuzz2 int Fixtures.auth "never branches when targetBranchCount is reached" <|
                    \seeder auth ->
                        let
                            targetReached =
                                List.length inputChildren >= auth.meta.targetBranchCount

                            selectedTip =
                                Experiment.Shaping.selectTip (Random.initialSeed seeder) auth input

                            branched =
                                selectedTip == inputRoot
                        in
                            (not targetReached || not branched)
                                |> Expect.true "Expected to not branch if targetBranchCount is reached"
                ]
            , describe "effects of branchProbability"
                [ fuzz2 int Fixtures.auth "never branches when branchProbability is 0" <|
                    \seeder auth ->
                        Experiment.Shaping.selectTip (Random.initialSeed seeder) (setBranchProbability 0 auth) input
                            |> Expect.notEqual inputRoot
                , fuzz2 int Fixtures.auth "when branchProbability > 0, always branches if targetBranchDepth is reached on all branches but targetBranchCount is not reached" <|
                    \seeder auth ->
                        let
                            targetCountReached =
                                List.length inputChildren >= auth.meta.targetBranchCount

                            allTargetDepthsReached =
                                Experiment.Shaping.tips input
                                    |> Nonempty.all (\( depth, _ ) -> depth >= auth.meta.targetBranchDepth)

                            selectedTip =
                                Experiment.Shaping.selectTip (Random.initialSeed seeder) auth input

                            branched =
                                selectedTip == inputRoot
                        in
                            (auth.meta.branchProbability == 0 || not (allTargetDepthsReached && not targetCountReached) || branched)
                                |> Expect.true "Expected to branch if targetBranchCount is not reached and targetBranchDepth is reached on all branches (when branchProbability > 0)"
                , fuzz2 int Fixtures.auth "always branches when branchProbability is 1 and targetBranchCount is not reached" <|
                    \seeder auth ->
                        let
                            targetReached =
                                List.length inputChildren >= auth.meta.targetBranchCount

                            selectedTip =
                                Experiment.Shaping.selectTip (Random.initialSeed seeder) (setBranchProbability 1 auth) input

                            branched =
                                selectedTip == inputRoot
                        in
                            (targetReached || branched)
                                |> Expect.true "Expected to branch if targetBranchCount is not reached"
                ]
            ]



-- Helpers


sample : Test
sample =
    describe "sample from a nonempty list"
        [ fuzz3 int int (list int) "produces a value from the list" <|
            \seeder head tail ->
                let
                    nonempty =
                        Nonempty head tail
                in
                    Helpers.sample (Random.initialSeed seeder) nonempty
                        |> (\e -> Nonempty.member e nonempty)
                        |> Expect.true "Expected the item to be a member of the list."
        ]


nonemptyMaximum : Test
nonemptyMaximum =
    describe "nonempty maximum"
        [ fuzz2 int (list int) "finds the maximum value in a list" <|
            \head tail ->
                let
                    nonempty =
                        Nonempty head tail
                in
                    Helpers.nonemptyMaximum nonempty
                        |> Just
                        |> Expect.equal (List.maximum <| head :: tail)
        ]


nonemptyMinimum : Test
nonemptyMinimum =
    describe "nonempty minimum"
        [ fuzz2 int (list int) "finds the minimum value in a list" <|
            \head tail ->
                let
                    nonempty =
                        Nonempty head tail
                in
                    Helpers.nonemptyMinimum nonempty
                        |> Just
                        |> Expect.equal (List.minimum <| head :: tail)
        ]
