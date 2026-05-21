module Main (main) where

import           System.Environment (lookupEnv)
import           Text.Read          (readMaybe)
import qualified Web.Scotty         as S

import           Tasks.Api          (app)
import           Tasks.Store        (newStore)

main :: IO ()
main = do
  port  <- maybe 3000 id . (>>= readMaybe) <$> lookupEnv "PORT"
  store <- newStore
  putStrLn $ "tasks-api listening on http://localhost:" <> show port
  S.scotty port (app store)
