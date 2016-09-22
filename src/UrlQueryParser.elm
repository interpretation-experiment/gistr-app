module UrlQueryParser
    exposing
        ( (</>)
        , (<?>)
        , QueryParser
        , UrlParser
        , custom
        , customQ
        , format
        , int
        , intQ
        , listQ
        , maybeQ
        , oneOf
        , parse
        , s
        , sQ
        , string
        , stringQ
        )

import Dict
import List
import Maybe.Extra exposing ((?))
import Result
import String


{-
   Things left to do:
   - url encoding/decoding of query parameters
   - decide between:
       (1) failing when some query parameters are left unparsed (current),
           meaning lists can be parsed as we do with listQ: it stops whenever
           a parameter fails parsing, and the overall parser will fail because
           of left over parameters
       (2) allowing left over parameters, meaning lists have to be parsed with
           their own dedicated intListQ and stringListQ (and customListQ)
           functions, because we can't distinguish between a failed parser and
           an unfound query argument without looking into the parser itself
           (or, we need to parameterise Parser's error type)
   - document everything
-}
-- PARSERS
{-
   We don't box these types (i.e. not doing `type Parser = Parser (...)`)
   because it prevents us from defining recursive parsers. Basically if you
   box these types, your recursive parser will necessarily be defined
   pointfree, running into
   [#873](https://github.com/elm-lang/elm-compiler/issues/873). To get around
   this we need to destructure the parsers to define recursion non pointfree.
-}


type alias Parser parts formatter result =
    parts -> formatter -> Result String ( parts, result )


type alias UrlParser formatter result =
    Parser ( Chunks, Items ) formatter result


type alias QueryParser formatter result =
    Parser Items formatter result


type alias PathParser formatter result =
    Parser Chunks formatter result



-- UTILITIES


type alias Chunks =
    List String


type alias Items =
    Dict.Dict String (List String)


queryItems : String -> Items
queryItems query =
    let
        grow ( key, value ) dict =
            Dict.update key (\l -> Just (value :: l ? [])) dict
    in
        List.map (splitFirst "=") (String.split "&" query)
            |> List.sort
            |> List.foldr grow Dict.empty


popItem : String -> Items -> Items
popItem key items =
    case Dict.get key items of
        Nothing ->
            items

        Just [] ->
            Dict.remove key items

        Just [ head ] ->
            Dict.remove key items

        Just (head :: rest) ->
            Dict.insert key rest items


itemsQuery : Items -> String
itemsQuery items =
    let
        expand ( key, values ) =
            List.map ((,) key) values
    in
        Dict.toList items
            |> List.sort
            |> List.map expand
            |> List.concat
            |> List.map (\( k, v ) -> k ++ "=" ++ v)
            |> String.join "&"


splitFirst : String -> String -> ( String, String )
splitFirst split str =
    let
        parts =
            String.split split str
    in
        ( List.head parts ? ""
        , String.join split (List.tail parts ? [ "" ])
        )



-- ACTUAL PARSING


parseWithoutRest :
    ( Chunks, Items )
    -> a
    -> UrlParser a b
    -> Result String b
parseWithoutRest ( chunks, items ) formatter actuallyParse =
    case actuallyParse ( chunks, items ) formatter of
        Err msg ->
            Err msg

        Ok ( ( restChunks, restItems ), result ) ->
            case ( restChunks, Dict.toList restItems ) of
                ( [], [] ) ->
                    Ok result

                ( [], [ ( "", [ "" ] ) ] ) ->
                    Ok result

                ( [ "" ], [] ) ->
                    Ok result

                ( [ "" ], [ ( "", [ "" ] ) ] ) ->
                    Ok result

                _ ->
                    Err <|
                        "The path and query parsers worked, but /"
                            ++ String.join "/" restChunks
                            ++ "?"
                            ++ itemsQuery restItems
                            ++ " was left over."


parse : a -> UrlParser a b -> String -> Result String b
parse formatter urlParser url =
    let
        ( path, query ) =
            splitFirst "?" url

        chunks =
            String.split "/" path

        items =
            queryItems query
    in
        parseWithoutRest ( chunks, items ) formatter urlParser



-- PARSER OPERATIONS


chain : Parser p a b -> Parser p b c -> Parser p a c
chain parseFirst parseRest =
    \parts func ->
        parseFirst parts func
            `Result.andThen`
                \( restParts, restFunc ) ->
                    parseRest restParts restFunc


queryToUrlParser : QueryParser a b -> UrlParser a b
queryToUrlParser parseQuery =
    \( chunks, items ) formatter ->
        parseQuery items formatter
            |> Result.map (\( i, r ) -> ( ( chunks, i ), r ))


pathToUrlParser : PathParser a b -> UrlParser a b
pathToUrlParser parsePath =
    \( chunks, items ) formatter ->
        parsePath chunks formatter
            |> Result.map (\( c, r ) -> ( ( c, items ), r ))


(</>) : UrlParser a b -> UrlParser b c -> UrlParser a c
(</>) firstParser secondParser =
    chain firstParser secondParser


(<?>) : UrlParser a b -> QueryParser b c -> UrlParser a c
(<?>) urlParser queryParser =
    chain urlParser (queryToUrlParser queryParser)


oneOf : List (UrlParser a b) -> UrlParser a b
oneOf choices =
    oneOfHelp choices


oneOfHelp :
    List (UrlParser a b)
    -> ( Chunks, Items )
    -> a
    -> Result String ( ( Chunks, Items ), b )
oneOfHelp choices parts formatter =
    case choices of
        [] ->
            Err "Tried many parsers, but none of them worked!"

        parseUrl :: otherParsers ->
            case (parseWithoutRest parts formatter parseUrl) of
                Err _ ->
                    oneOfHelp otherParsers parts formatter

                Ok result ->
                    Ok ( ( [], Dict.empty ), result )


format : formatter -> Parser p formatter a -> Parser p (a -> result) result
format input parse =
    \parts func ->
        case parse parts input of
            Err msg ->
                Err msg

            Ok ( newParts, value ) ->
                Ok ( newParts, func value )



-- QUERY PARSER CONSTRUCTION


sQ : String -> QueryParser a a
sQ key =
    \items result ->
        case Dict.get key items of
            Just (value :: rest) ->
                Ok ( popItem key items, result )

            _ ->
                Err ("Didn't find query parameter " ++ key)


maybeQ : QueryParser (a -> a) a -> QueryParser (Maybe a -> b) b
maybeQ parseQuery =
    \items func ->
        case parseQuery items identity of
            Err _ ->
                Ok ( items, func Nothing )

            Ok ( newItems, result ) ->
                Ok ( newItems, func (Just result) )


listQ : QueryParser (a -> a) a -> QueryParser (List a -> b) b
listQ queryParser =
    \items func ->
        let
            ( restItems, results ) =
                parseUntil queryParser items []
        in
            Ok ( restItems, func (List.reverse results) )


parseUntil : QueryParser (a -> a) a -> Items -> List a -> ( Items, List a )
parseUntil queryParser items results =
    let
        parseQuery =
            queryParser
    in
        case parseQuery items identity of
            Err _ ->
                ( items, results )

            Ok ( restItems, result ) ->
                parseUntil queryParser restItems (result :: results)


stringQ : String -> QueryParser (String -> a) a
stringQ =
    customQ "STRING" Ok


intQ : String -> QueryParser (Int -> a) a
intQ =
    customQ "NUMBER" String.toInt


customQ :
    String
    -> (String -> Result String a)
    -> String
    -> QueryParser (a -> output) output
customQ tipe stringToSomething key =
    \items func ->
        case Dict.get key items of
            Just (value :: rest) ->
                case stringToSomething value of
                    Ok something ->
                        Ok
                            ( popItem key items
                            , func something
                            )

                    Err msg ->
                        Err
                            ("Parsing `"
                                ++ value
                                ++ "` went wrong: "
                                ++ msg
                            )

            _ ->
                Err
                    ("Didn't find query parameter "
                        ++ key
                        ++ "="
                        ++ tipe
                    )



-- URL PARSER CONSTRUCTION


s : String -> UrlParser a a
s str =
    pathToUrlParser <|
        \chunks result ->
            case chunks of
                [] ->
                    Err ("Got to the end of the URL but wanted /" ++ str)

                chunk :: remaining ->
                    if chunk == str then
                        Ok ( remaining, result )
                    else
                        Err
                            ("Wanted /"
                                ++ str
                                ++ " but got /"
                                ++ String.join "/" chunks
                            )


string : UrlParser (String -> a) a
string =
    custom "STRING" Ok


int : UrlParser (Int -> a) a
int =
    custom "NUMBER" String.toInt


custom : String -> (String -> Result String a) -> UrlParser (a -> output) output
custom tipe stringToSomething =
    pathToUrlParser <|
        \chunks func ->
            case chunks of
                [] ->
                    Err ("Got to the end of the URL but wanted /" ++ tipe)

                chunk :: remaining ->
                    case stringToSomething chunk of
                        Ok something ->
                            Ok ( remaining, func something )

                        Err msg ->
                            Err
                                ("Parsing `"
                                    ++ chunk
                                    ++ "` went wrong: "
                                    ++ msg
                                )
