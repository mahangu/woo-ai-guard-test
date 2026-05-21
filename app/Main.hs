module Main (main) where

import           Data.String              (fromString)
import           Network.Wai.Handler.Warp (defaultSettings, setHost, setPort)
import           System.Environment       (lookupEnv)
import           Text.Read                (readMaybe)
import qualified Web.Scotty               as S

import           Tasks.Api                (app)
import           Tasks.Store              (newStore)

main :: IO ()
main = do
  port  <- maybe 3000 id . (>>= readMaybe) <$> lookupEnv "PORT"
  host  <- maybe "127.0.0.1" id <$> lookupEnv "HOST"
  store <- newStore
  let warpSettings = setHost (fromString host) (setPort port defaultSettings)
      opts         = S.defaultOptions { S.settings = warpSettings }
  putStrLn $ "tasks-api listening on http://" <> host <> ":" <> show port
  S.scottyOpts opts (app store)
