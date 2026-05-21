{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import           Data.Aeson           (decode, encode, object, (.=))
import qualified Data.ByteString.Lazy as BL
import           Test.Hspec
import           Test.Hspec.Wai
import qualified Web.Scotty           as S

import           Tasks.Api            (app)
import           Tasks.Store          (newStore)
import           Tasks.Types          (Task (..))

main :: IO ()
main = hspec spec

spec :: Spec
spec = with mkApp $ describe "tasks-api" $ do
  it "answers /health" $
    get "/health" `shouldRespondWith` 200

  it "starts with an empty list" $
    get "/tasks" `shouldRespondWith` "[]" { matchStatus = 200 }

  it "creates, reads, updates, and deletes a task" $ do
    -- create
    res <- request "POST" "/tasks" jsonHeaders (encode (object ["title" .= ("write tests" :: String)]))
    case decode (simpleBody res) :: Maybe Task of
      Nothing -> liftIO (expectationFailure "POST /tasks did not return a Task")
      Just t  -> do
        liftIO (taskTitle t `shouldBe` "write tests")
        liftIO (taskDone  t `shouldBe` False)
        let idPath = "/tasks/" <> BL.toStrict (encodeInt (taskId t))
        get idPath `shouldRespondWith` 200
        -- patch
        _ <- request "PATCH" idPath jsonHeaders (encode (object ["done" .= True]))
        -- delete
        request "DELETE" idPath [] "" `shouldRespondWith` 204
        get idPath `shouldRespondWith` 404
  where
    jsonHeaders = [("Content-Type", "application/json")]
    encodeInt   = encode

    mkApp = do
      store <- newStore
      S.scottyApp (app store)
