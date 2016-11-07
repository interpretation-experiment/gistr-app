module Store
    exposing
        ( Store
        , Item(..)
        , TypedStore
        , decoder
        , emptyStore
        , encoder
        , endpoint
        , get
        , newEncoder
        , set
        )

import Decoders
import Dict
import Encoders
import Json.Decode as JD
import Json.Encode as JE
import Types


type alias Converter a b =
    { newEncoder : b -> JE.Value
    , encoder : a -> JE.Value
    , decoder : JD.Decoder a
    }


type Item
    = WordSpan Types.WordSpan
    | Profile Types.Profile


type TypedStore a b
    = TypedStore
        { endpoint : String
        , converter : Converter a b
        , data : Dict.Dict Int a
        }


type alias Store =
    { wordSpans : TypedStore Types.WordSpan Types.NewWordSpan
    , profiles : TypedStore Types.Profile (Maybe String)
    , sentences : TypedStore Types.Sentence Types.NewSentence
    , trees : TypedStore Types.Tree ()
    , meta : Maybe Types.Meta
    }


emptyStore : Store
emptyStore =
    { wordSpans =
        TypedStore
            { endpoint = "word-spans"
            , converter =
                { newEncoder = Encoders.newWordSpan
                , encoder = always JE.null
                , decoder = Decoders.wordSpan
                }
            , data = Dict.empty
            }
    , profiles =
        TypedStore
            { endpoint = "profiles"
            , converter =
                { newEncoder = Encoders.newProfile
                , encoder = Encoders.profile
                , decoder = Decoders.profile
                }
            , data = Dict.empty
            }
    , sentences =
        TypedStore
            { endpoint = "sentences"
            , converter =
                { newEncoder = Encoders.newSentence
                , encoder = always JE.null
                , decoder = Decoders.sentence
                }
            , data = Dict.empty
            }
    , trees =
        TypedStore
            { endpoint = "trees"
            , converter =
                { newEncoder = always JE.null
                , encoder = always JE.null
                , decoder = Decoders.tree
                }
            , data = Dict.empty
            }
    , meta = Nothing
    }


get : Int -> TypedStore a b -> Maybe a
get id (TypedStore { data }) =
    Dict.get id data


set : Item -> Store -> Store
set item store =
    case item of
        WordSpan wordSpan ->
            { store | wordSpans = setTyped wordSpan.id wordSpan store.wordSpans }

        Profile profile ->
            { store | profiles = setTyped profile.id profile store.profiles }


setTyped : Int -> a -> TypedStore a b -> TypedStore a b
setTyped id value (TypedStore typedStore) =
    TypedStore { typedStore | data = Dict.insert id value typedStore.data }


endpoint : TypedStore a b -> String
endpoint (TypedStore { endpoint }) =
    endpoint


decoder : TypedStore a b -> JD.Decoder a
decoder (TypedStore { converter }) =
    converter.decoder


encoder : TypedStore a b -> (a -> JE.Value)
encoder (TypedStore { converter }) =
    converter.encoder


newEncoder : TypedStore a b -> (b -> JE.Value)
newEncoder (TypedStore { converter }) =
    converter.newEncoder
