module Router
    exposing
        ( Route(..)
        , ProfileRoute(..)
        , locationParser
        , toUrl
        )

import Navigation
import String
import UrlQueryParser
    exposing
        ( (</>)
        , (<?>)
        , UrlParser
        , format
        , oneOf
        , s
        , stringQ
        )


-- ROUTES


type Route
    = Home
    | About
    | Login
    | Recover
    | Reset String String
    | Profile ProfileRoute


type ProfileRoute
    = Tests
    | Settings
    | Emails



-- URL -> ROUTE


locationParser : Navigation.Location -> ( String, Maybe Route )
locationParser location =
    let
        path =
            location.pathname

        query =
            location.search
    in
        ( path ++ query
        , String.dropLeft 1 path
            ++ query
            |> UrlQueryParser.parse identity urlParser
            |> Result.toMaybe
        )


{-|
    Can't define a hypothetical routeQ here

    ```
    import UrlQueryParser exposing (QueryParser, customQ)

    routeQ : String -> QueryParser (Route -> a) a
    routeQ key =
        customQ "ROUTE" (UrlQueryParser.parse identity urlParser) key
    ```

    as it runs into [#873](https://github.com/elm-lang/elm-compiler/issues/873).
-}
urlParser : UrlParser (Route -> a) a
urlParser =
    oneOf
        [ format Home (s "")
        , format About (s "about")
        , format Recover (s "login" </> s "recover")
        , format Reset
            (s "login" </> s "reset" <?> stringQ "uid" <?> stringQ "token")
        , format Login (s "login")
        , format Profile (s "profile" </> profileUrlParser)
        , format (Profile Tests) (s "profile")
        ]


profileUrlParser : UrlParser (ProfileRoute -> a) a
profileUrlParser =
    oneOf
        [ format Tests (s "tests")
        , format Settings (s "settings")
        , format Emails (s "emails")
        ]



-- ROUTE -> URL


toUrl : Route -> String
toUrl route =
    case route of
        Home ->
            "/"

        About ->
            "/about"

        Login ->
            "/login"

        Recover ->
            "/login/recover"

        Reset uid token ->
            "/login/reset?token=" ++ token ++ "&uid=" ++ uid

        Profile profileRoute ->
            "/profile" ++ (toProfileUrl profileRoute)


toProfileUrl : ProfileRoute -> String
toProfileUrl profileRoute =
    case profileRoute of
        Tests ->
            "/tests"

        Settings ->
            "/settings"

        Emails ->
            "/emails"
