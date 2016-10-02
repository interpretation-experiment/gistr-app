module Form
    exposing
        ( Model
        , Status(..)
        , animate
        , empty
        , fail
        , form
        , input
        , setFeedback
        , setInput
        , setStatus
        , succeed
        , successAnimations
        )

import Animation
import Feedback


type Status
    = Entering
    | Confirming
    | Sending


type alias Model a =
    { input : a, feedback : Feedback.Feedback, status : Status }


empty : a -> Model a
empty input =
    { input = input, feedback = Feedback.empty, status = Entering }


form : a -> Feedback.Feedback -> Status -> Model a
form input feedback status =
    { input = input, feedback = feedback, status = status }



-- HELPERS


input : a -> Model a -> Model a
input input form =
    form
        |> setInput input
        |> setFeedback Feedback.empty


fail : Feedback.Feedback -> Model a -> Model a
fail feedback form =
    form
        |> setFeedback feedback
        |> setStatus Entering


succeed : a -> Feedback.Feedback -> Model a -> Model a
succeed input feedback form =
    form
        |> setInput input
        |> setFeedback feedback
        |> setStatus Entering


animate : Animation.Msg -> Model a -> Model a
animate msg form =
    form
        |> setFeedback (Feedback.animate msg form.feedback)


successAnimations : Model a -> List (Animation.State)
successAnimations { feedback } =
    Feedback.successAnimations feedback


setInput : a -> Model a -> Model a
setInput input { feedback, status } =
    form input feedback status


setFeedback : Feedback.Feedback -> Model a -> Model a
setFeedback feedback { input, status } =
    form input feedback status


setStatus : Status -> Model a -> Model a
setStatus status { input, feedback } =
    form input feedback status
