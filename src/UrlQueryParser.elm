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


type alias Parser error parts formatter result =
    parts -> formatter -> Result error ( parts, result )


type alias UrlParser formatter result =
    Parser String ( Chunks, Items ) formatter result


type QueryError
    = NotFound String
    | BadFormat String


type alias QueryParser formatter result =
    Parser QueryError Items formatter result


type alias PathParser formatter result =
    Parser String Chunks formatter result



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


removeItem : String -> Items -> Items
removeItem key items =
    case Dict.get key items of
        Nothing ->
            items

        Just [] ->
            Dict.remove key items

        Just [ _ ] ->
            Dict.remove key items

        Just (_ :: rest) ->
            Dict.insert key rest items


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


parseFullPath :
    ( Chunks, Items )
    -> a
    -> UrlParser a b
    -> Result String b
parseFullPath ( chunks, items ) formatter actuallyParse =
    case actuallyParse ( chunks, items ) formatter of
        Err msg ->
            Err msg

        Ok ( ( restChunks, restItems ), result ) ->
            case restChunks of
                [] ->
                    Ok result

                [ "" ] ->
                    Ok result

                _ ->
                    Err <|
                        "The path and query parsers worked, but /"
                            ++ String.join "/" restChunks
                            ++ " (and possibly some query parameters) was left over"


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
        parseFullPath ( chunks, items ) formatter urlParser



-- PARSER OPERATIONS


chain : Parser e p a b -> Parser e p b c -> Parser e p a c
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
            |> Result.formatError toString


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
            case parseFullPath parts formatter parseUrl of
                Err _ ->
                    oneOfHelp otherParsers parts formatter

                Ok result ->
                    Ok ( ( [], Dict.empty ), result )


format : formatter -> Parser e p formatter a -> Parser e p (a -> result) result
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
                Ok ( removeItem key items, result )

            _ ->
                Err (NotFound ("Didn't find query parameter " ++ key))


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
        case listQHelp queryParser [] items of
            Err error ->
                Err error

            Ok ( restItems, results ) ->
                Ok ( restItems, func (List.reverse results) )


listQHelp : QueryParser (a -> a) a -> List a -> Items -> Result QueryError ( Items, List a )
listQHelp parseQuery results items =
    case parseQuery items identity of
        Err (BadFormat msg) ->
            Err (BadFormat msg)

        Err (NotFound msg) ->
            case results of
                [] ->
                    Err (NotFound msg)

                _ ->
                    Ok ( items, results )

        Ok ( restItems, result ) ->
            listQHelp parseQuery (result :: results) restItems


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
                            ( removeItem key items
                            , func something
                            )

                    Err msg ->
                        Err <|
                            BadFormat
                                ("Parsing `"
                                    ++ value
                                    ++ "` went wrong: "
                                    ++ msg
                                )

            _ ->
                Err <|
                    NotFound
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
