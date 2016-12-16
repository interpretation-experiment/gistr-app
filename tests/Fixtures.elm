module Fixtures exposing (auth)

import Date
import Fuzz exposing (Fuzzer)
import Types


staticToken : Types.Token
staticToken =
    "dummy-static-token"


staticUser : Types.User
staticUser =
    let
        userData =
            { userId = 45, userUsername = "joe" }
    in
        { id = userData.userId
        , username = userData.userUsername
        , isActive = True
        , isStaff = False
        , profile = staticProfile userData
        , emails = []
        }


staticProfile : { userId : Int, userUsername : String } -> Types.Profile
staticProfile { userId, userUsername } =
    { id = 50
    , -- Wed Dec 07 2016 13:00:18 GMT+0100 (CET)
      created = Date.fromTime 1481112018000
    , prolificId = Nothing
    , mothertongue = "enligsh"
    , trained = False
    , introducedExpHome = False
    , introducedExpPlay = False
    , userId = userId
    , questionnaireId = Nothing
    , wordSpanId = Nothing
    , commentsIds = []
    , sentencesIds = []
    , treesIds = []
    , userUsername = userUsername
    , reformulationsCount = 0
    , availableTreeCounts = { training = 5, experiment = 50 }
    }


meta : Fuzzer Types.Meta
meta =
    let
        base =
            { targetBranchDepth = 8
            , targetBranchCount = 6
            , branchProbability = 0.2
            , readFactor = 1
            , writeFactor = 5
            , minTokens = 10
            , genderChoices = []
            , educationLevelChoices = []
            , jobTypeChoices = []
            , bucketChoices = []
            , experimentWork = 50
            , trainingWork = 5
            , treeCost = 50
            , baseCredit = 0
            , defaultLanguge = "english"
            , supportedLanguages = []
            , otherLanguage = "other"
            }
    in
        Fuzz.map3
            (\branchProbability branchCount branchDepth ->
                { base
                    | branchProbability = branchProbability
                    , targetBranchCount = branchCount
                    , targetBranchDepth = branchDepth
                }
            )
            (Fuzz.floatRange 0 1)
            (Fuzz.intRange 0 100)
            (Fuzz.intRange 0 100)


auth : Fuzzer Types.Auth
auth =
    Fuzz.map (Types.Auth staticToken staticUser) meta
