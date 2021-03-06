{--License: license.txt --}
module CCAR.Model.Survey 
    (manageSurvey)
where 
import Control.Monad.IO.Class 
import Control.Monad.Logger 
import Control.Applicative as Appl
import Database.Persist
import Database.Persist.Postgresql as Postgresql 
import Database.Persist.TH 
import CCAR.Main.DBUtils
import CCAR.Command.ApplicationError 
import Data.Text as T 
import qualified CCAR.Main.EnumeratedTypes as EnumeratedTypes 
import qualified CCAR.Main.GroupCommunication as GC
import Data.Aeson
import Data.Aeson.Encode as En
import Data.Aeson.Types as AeTypes(Result(..), parse)
import Data.Monoid
import Data.Text.Lazy.Encoding as E
import Data.Text.Lazy as L 

import GHC.Generics
import Data.Data
import Data.Typeable 
import Data.Time
import CCAR.Main.Util 

data CRUD = Create | Read | Survey_Update | Delete
    deriving(Show, Eq, Read, Data, Generic, Typeable)

data CommandManageSurvey = CommandManageSurvey {
        nickName :: T.Text
        , crudType :: CRUD 
        , survey :: Survey
    } deriving (Show, Eq)




rSurvey = undefined
dSurvey = undefined 


-- When the creator and user updating are not same. 
-- This is to allow group members : members authorized to 
-- tweak a survey.
updateSurveyFor updNickName creatorNickName survey = undefined

-- Survey can only be updated by the creator by default.
uSurvey aNickName survey currentTime = do 
        mP <- getBy $ UniqueNickName aNickName
        sId <- case mP of 
            Just (Entity kP p ) -> do
                surveyE <- getBy $ UniqueSurvey kP $ surveySurveyTitle survey
                case surveyE of 
                    Just (Entity kS vS)  -> 
                                    Postgresql.replace kS $ 
                                        survey {surveyUpdatedBy = kP  
                                            , surveyUpdatedOn = currentTime}
        return sId

iSurvey aNickName survey  = do 
            mP <- getBy $ UniqueNickName aNickName
            surveyId <- case mP of 
                    Just (Entity k p) -> insert $ survey {surveyCreatedBy = k, surveyUpdatedBy = k}
            return surveyId

insertSurvey aNickName survey  = dbOps $ iSurvey aNickName survey

updateSurvey aNickName survey  = do 
    currentTime <- getCurrentTime
    dbOps $ uSurvey aNickName survey currentTime

readSurvey aNick survey = dbOps $ rSurvey nickName survey 
deleteSurvey aNick survey = dbOps $ dSurvey nickName survey 


-- "ad","and","Andorra",".ad"

defaultCountry = insert $ Country "and" "ad" "Andorra" ".ad"

defaultIdentificationZone = do 
    country <- defaultCountry
    insert $ IdentificationZone "NJ" "08820" country

process c@(CommandManageSurvey nickName crudType survey) = do 
    case crudType of
        Create -> do 
                    _ <- insertSurvey nickName survey
                    return (GC.Reply, serialize c)
        Survey_Update -> do                 
                x <- updateSurvey nickName survey
                return (GC.Reply, serialize x)
        Read -> readSurvey nickName survey
        Delete -> deleteSurvey nickName survey          


manageSurvey nickName  a  =
        case (parse parseJSON a :: Result CommandManageSurvey) of
            Success r ->  process r 
            Error s -> return (GC.Reply, 
                        serialize $ appError $ "Sending message failed " ++ s ++ (show a))



gen (CommandManageSurvey nickName crudType survey) = object ["crudType" .= crudType
                    , "survey" .= survey
                    , "commandType" .= ("ManageSurvey" :: T.Text)
                    , "nickName" .= nickName]

parseMS v = CommandManageSurvey <$>
                    v .: "nickName" <*> 
                    v .: "crudType" <*>
                    v .: "survey"


instance ToJSON CRUD 
instance FromJSON CRUD 
instance ToJSON CommandManageSurvey where
    toJSON  = gen

instance FromJSON CommandManageSurvey where 
    parseJSON (Object v ) = parseMS v 
    parseJSON _           = Appl.empty

