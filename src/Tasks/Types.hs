{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Tasks.Types
  ( TaskId
  , Task (..)
  , NewTask (..)
  , TaskPatch (..)
  , applyPatch
  ) where

import           Data.Aeson   (FromJSON (..), ToJSON (..), object, withObject,
                               (.:), (.:?), (.=))
import           Data.Text    (Text)
import           GHC.Generics (Generic)

type TaskId = Int

data Task = Task
  { taskId    :: !TaskId
  , taskTitle :: !Text
  , taskDone  :: !Bool
  } deriving (Eq, Show, Generic)

instance ToJSON Task where
  toJSON t = object
    [ "id"    .= taskId t
    , "title" .= taskTitle t
    , "done"  .= taskDone t
    ]

instance FromJSON Task where
  parseJSON = withObject "Task" $ \o ->
    Task <$> o .: "id"
         <*> o .: "title"
         <*> o .: "done"

-- | The body accepted by @POST /tasks@. Done defaults to False when absent.
data NewTask = NewTask
  { newTitle :: !Text
  , newDone  :: !Bool
  } deriving (Eq, Show)

instance FromJSON NewTask where
  parseJSON = withObject "NewTask" $ \o ->
    NewTask <$> o .:  "title"
            <*> (maybe False id <$> o .:? "done")

-- | The body accepted by @PATCH /tasks/:id@. Either field may be omitted.
data TaskPatch = TaskPatch
  { patchTitle :: !(Maybe Text)
  , patchDone  :: !(Maybe Bool)
  } deriving (Eq, Show)

instance FromJSON TaskPatch where
  parseJSON = withObject "TaskPatch" $ \o ->
    TaskPatch <$> o .:? "title"
              <*> o .:? "done"

applyPatch :: TaskPatch -> Task -> Task
applyPatch p t = t
  { taskTitle = maybe (taskTitle t) id (patchTitle p)
  , taskDone  = maybe (taskDone  t) id (patchDone  p)
  }
