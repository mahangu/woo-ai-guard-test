{-# LANGUAGE BangPatterns #-}

module Tasks.Store
  ( Store
  , newStore
  , listTasks
  , getTask
  , createTask
  , updateTask
  , deleteTask
  ) where

import           Control.Concurrent.STM (STM, TVar, atomically, newTVarIO,
                                         readTVar, readTVarIO, writeTVar)
import qualified Data.IntMap.Strict     as IntMap
import           Data.IntMap.Strict     (IntMap)
import           Tasks.Types            (NewTask (..), Task (..), TaskId,
                                         TaskPatch, applyPatch)

-- | An in-memory store: the next id to hand out, plus the current task map.
data Store = Store
  { storeNext  :: !(TVar TaskId)
  , storeTasks :: !(TVar (IntMap Task))
  }

newStore :: IO Store
newStore = Store <$> newTVarIO 1 <*> newTVarIO IntMap.empty

listTasks :: Store -> IO [Task]
listTasks s = IntMap.elems <$> readTVarIO (storeTasks s)

getTask :: Store -> TaskId -> IO (Maybe Task)
getTask s tid = IntMap.lookup tid <$> readTVarIO (storeTasks s)

createTask :: Store -> NewTask -> IO Task
createTask s nt = atomically $ do
  tid <- readTVar (storeNext s)
  writeTVar (storeNext s) (tid + 1)
  let task = Task { taskId = tid, taskTitle = newTitle nt, taskDone = newDone nt }
  modifyTVar' (storeTasks s) (IntMap.insert tid task)
  pure task

updateTask :: Store -> TaskId -> TaskPatch -> IO (Maybe Task)
updateTask s tid patch = atomically $ do
  tasks <- readTVar (storeTasks s)
  case IntMap.lookup tid tasks of
    Nothing -> pure Nothing
    Just t  -> do
      let t' = applyPatch patch t
      writeTVar (storeTasks s) (IntMap.insert tid t' tasks)
      pure (Just t')

deleteTask :: Store -> TaskId -> IO Bool
deleteTask s tid = atomically $ do
  tasks <- readTVar (storeTasks s)
  if IntMap.member tid tasks
    then do
      writeTVar (storeTasks s) (IntMap.delete tid tasks)
      pure True
    else pure False

modifyTVar' :: TVar a -> (a -> a) -> STM ()
modifyTVar' tv f = do
  x <- readTVar tv
  let !x' = f x
  writeTVar tv x'
