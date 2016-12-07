module Tests exposing (..)

import Expect
import Fuzz exposing (list, int, tuple, string)
import Experiment.Shaping
import String
import Test exposing (..)


all : Test
all =
    describe "Gistr Test Suite"
        [ describe "Experiment.Shaping"
            [ tree ]
        , describe "Fuzz test examples, using randomly generated input"
            [ fuzz (list int) "Lists always have positive length" <|
                \aList ->
                    List.length aList |> Expect.atLeast 0
            , fuzz (list int) "Sorting a list does not change its length" <|
                \aList ->
                    List.sort aList |> List.length |> Expect.equal (List.length aList)
            , fuzzWith { runs = 1000 } int "List.member will find an integer in a list containing it" <|
                \i ->
                    List.member i [ i ] |> Expect.true "If you see this, List.member returned False!"
            , fuzz2 string string "The length of a string equals the sum of its substrings' lengths" <|
                \s1 s2 ->
                    s1 ++ s2 |> String.length |> Expect.equal (String.length s1 + String.length s2)
            ]
        ]


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
    in
        describe "tree building"
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
                        |> Expect.equal (Experiment.Shaping.Tree 3 [])
            ]
