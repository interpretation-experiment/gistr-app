module Profile.Msg exposing (Msg(..))

import Api
import Types


type Msg
    = -- PASSWORD MANAGEMENT
      ChangePasswordFormInput Types.PasswordCredentials
    | ChangePassword Types.PasswordCredentials
    | ChangePasswordResult (Api.Result Types.Auth)
    | ChangePasswordRecover
    | ChangePasswordRecoverResult String (Api.Result ())
      -- USERNAME MANAGEMENT
    | ChangeUsernameFormInput String
    | ChangeUsername String
    | ChangeUsernameResult (Api.Result Types.User)
      -- EMAIL MANAGEMENT
    | VerifyEmail Types.Email
    | VerifyEmailResult Types.Email (Api.Result ())
    | ConfirmEmailResult (Api.Result Types.User)
    | PrimaryEmail Types.Email
    | PrimaryEmailResult (Api.Result Types.User)
    | DeleteEmail Types.Email
    | DeleteEmailResult (Api.Result Types.User)
    | AddEmailFormInput String
    | AddEmail String
    | AddEmailResult String (Api.Result Types.User)
      -- QUESTIONNAIRE
    | QuestionnaireFormInput Types.QuestionnaireForm
    | QuestionnaireFormConfirm Types.QuestionnaireForm
    | QuestionnaireFormCorrect
    | QuestionnaireFormSubmit Types.QuestionnaireForm
    | QuestionnaireFormResult (Api.Result Types.Profile)
