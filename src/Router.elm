module Router
    exposing
        ( Route(..)
        , ProfileRoute(..)
        , locationParser
        , toUrl
        )

import String
import Navigation
import UrlParser exposing (Parser, (</>), format, oneOf, s)


-- ROUTES


type Route
    = Home
    | About
    | Profile ProfileRoute


type ProfileRoute
    = Tests
    | Settings
    | Emails


locationParser : Navigation.Location -> ( String, Maybe Route )
locationParser location =
    let
        path =
            location.pathname
    in
        ( path
        , UrlParser.parse identity urlParser (String.dropLeft 1 path)
            |> Result.toMaybe
        )


urlParser : Parser (Route -> a) a
urlParser =
    oneOf
        [ format Home (s "")
        , format About (s "about")
        , format Profile (s "profile" </> profileUrlParser)
        , format (Profile Tests) (s "profile")
        ]


profileUrlParser : Parser (ProfileRoute -> a) a
profileUrlParser =
    oneOf
        [ format Tests (s "tests")
        , format Settings (s "settings")
        , format Emails (s "emails")
        ]



-- REVERSE ROUTING


toUrl : Route -> String
toUrl route =
    case route of
        Home ->
            "/"

        About ->
            "/about"

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
