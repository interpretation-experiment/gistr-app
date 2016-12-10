module Autoresize
    exposing
        ( Model
        , Msg
        , initialModel
        , textarea
        , update
        )

import Dict
import Dom
import Dom.Size
import Html
import Html.Attributes as Attributes
import Html.Events as Events
import Styles exposing (class, classList, id)
import Task


-- MODEL


type Model
    = Model (Dict.Dict String Textarea)


initialModel : Model
initialModel =
    Model Dict.empty


type alias Textarea =
    { contentHeight : Float
    , contentWidth : Float
    }


initialTextarea : Textarea
initialTextarea =
    { contentHeight = 0
    , contentWidth = 0
    }


modelGet : String -> Model -> Textarea
modelGet id (Model model) =
    Dict.get id model
        |> Maybe.withDefault initialTextarea


modelUpdate : String -> Model -> (Textarea -> Textarea) -> Model
modelUpdate id (Model model) update =
    Model <|
        Dict.update id
            (Maybe.withDefault initialTextarea >> update >> Just)
            model



-- UPDATE


type Msg msg
    = InputText String msg
    | GotDetails String (Result Dom.Error ( Float, Float ))


update : (Msg msg -> msg) -> Msg msg -> Model -> ( Model, Cmd msg, Maybe msg )
update lift msg model =
    case msg of
        InputText id outMsg ->
            ( model
            , Task.map2 (,)
                (Dom.Size.height Dom.Size.Content (hiddenId id))
                (Dom.Size.width Dom.Size.Content id)
                |> Task.attempt (GotDetails id)
                |> Cmd.map lift
            , Just outMsg
            )

        GotDetails id (Err _) ->
            update lift (GotDetails id <| Ok ( 0, 0 )) model

        GotDetails id (Ok ( height, width )) ->
            ( modelUpdate id
                model
                (\textarea ->
                    { textarea
                        | -- heightWithPadding + borders
                          contentHeight = height + 2
                        , -- widthWithPadding + borders
                          contentWidth = width + 2
                    }
                )
            , Cmd.none
            , Nothing
            )



-- VIEW


type alias ViewConfig msg =
    { lift : Msg msg -> msg
    , model : Model
    , id : String
    , onInput : String -> msg
    }


textarea : ViewConfig msg -> List (Html.Attribute msg) -> String -> Html.Html msg
textarea { lift, model, id, onInput } attrs content =
    let
        details =
            if String.isEmpty content then
                initialTextarea
            else
                modelGet id model
    in
        Html.div []
            [ Html.textarea
                ([ Events.onInput (lift << InputText id << onInput)
                 , Attributes.style
                    [ ( "height", toString details.contentHeight ++ "px" ) ]
                 , Attributes.id id
                 , Attributes.value content
                 ]
                    ++ attrs
                )
                []
            , Html.div
                [ Attributes.style
                    [ ( "width", toString details.contentWidth ++ "px" ) ]
                , Attributes.id (hiddenId id)
                , class [ Styles.TextareaHiddenContent ]
                ]
                (content
                    |> String.split "\n"
                    |> List.map Html.text
                    |> List.intersperse (Html.br [] [])
                )
            ]



-- UTILS


hiddenId : String -> String
hiddenId id =
    id ++ "HiddenContent"
