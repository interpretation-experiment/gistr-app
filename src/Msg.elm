module Msg exposing (Msg(..))

import Animation
import Auth.Msg as Auth
import Instructions
import Router
import Store
import Types


type Msg
    = NoOp
    | Animate Animation.Msg
      -- NAVIGATION
    | NavigateTo Router.Route
    | Error Types.Error
      -- AUTH
    | AuthMsg Auth.Msg
      -- PASSWORD MANAGEMENT
    | ChangePasswordFormInput Types.PasswordCredentials
    | ChangePasswordFail Types.Error
    | ChangePassword Types.PasswordCredentials
    | ChangePasswordSuccess Types.Auth
    | ChangePasswordRecover
    | ChangePasswordRecoverSuccess
      -- USERNAME MANAGEMENT
    | ChangeUsernameFormInput String
    | ChangeUsernameFail Types.Error
    | ChangeUsername String
    | ChangeUsernameSuccess Types.User
      -- EMAIL MANAGEMENT
    | RequestEmailVerification Types.Email
    | RequestEmailVerificationSuccess Types.Email
    | EmailConfirmationFail Types.Error
    | EmailConfirmationSuccess Types.User
    | PrimaryEmail Types.Email
    | PrimaryEmailSuccess Types.User
    | DeleteEmail Types.Email
    | DeleteEmailSuccess Types.User
    | AddEmailFormInput String
    | AddEmailFail Types.Error
    | AddEmail String
    | AddEmailSuccess Types.User
      -- QUESTIONNAIRE
    | QuestionnaireFormInput Types.QuestionnaireForm
    | QuestionnaireFormConfirm Types.QuestionnaireForm
    | QuestionnaireFormCorrect
    | QuestionnaireFormSubmit Types.QuestionnaireForm
    | QuestionnaireFormFail Types.Error
    | QuestionnaireFormSuccess Types.User
      -- STORE
    | GotStoreItem Store.Item
    | GotMeta Types.Meta
      -- REFORMULATIONS EXPERIMENT
    | ReformulationInstructions Instructions.Msg
    | ReformulationInstructionsRestart
    | ReformulationInstructionsQuit Int
    | ReformulationInstructionsDone
    | ReformulationExpStart
