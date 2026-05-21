{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Tasks.Api
  ( app
  ) where

import           Data.Aeson         (object, (.=))
import qualified Data.Text.Lazy     as LT
import           Network.HTTP.Types (status201, status204, status404)
import qualified Web.Scotty         as S

import           Tasks.Store        (Store, createTask, deleteTask, getTask,
                                     listTasks, updateTask)
import           Tasks.Types        (NewTask, TaskId, TaskPatch)

app :: Store -> S.ScottyM ()
app store = do
  S.get "/health" $
    S.json (object ["status" .= ("ok" :: String)])

  S.get "/tasks" $ do
    tasks <- io (listTasks store)
    S.json tasks

  S.get "/tasks/:id" $ do
    tid <- S.param "id"
    mTask <- io (getTask store tid)
    case mTask of
      Just t  -> S.json t
      Nothing -> notFound tid

  S.post "/tasks" $ do
    body :: NewTask <- S.jsonData
    created <- io (createTask store body)
    S.status status201
    S.json created

  S.patch "/tasks/:id" $ do
    tid <- S.param "id"
    body :: TaskPatch <- S.jsonData
    mTask <- io (updateTask store tid body)
    case mTask of
      Just t  -> S.json t
      Nothing -> notFound tid

  S.delete "/tasks/:id" $ do
    tid <- S.param "id"
    ok  <- io (deleteTask store tid)
    if ok
      then do
        S.status status204
        S.raw ""
      else notFound tid
  where
    io = S.liftAndCatchIO

    notFound :: TaskId -> S.ActionM ()
    notFound tid = do
      S.status status404
      S.json (object [ "error" .= ("task not found" :: LT.Text)
                     , "id"    .= tid
                     ])
