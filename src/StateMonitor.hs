{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module StateMonitor
  ( newMessage,
  )
where

import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import Data.Text
import GHC.Generics

newtype Message = Message
  { event :: Text
  }
  deriving (Show, Generic, FromJSON, ToJSON)

newMessage :: Show a => a -> ByteString -> IO ()
newMessage topic message = do
  print $ "Received an event:" <> show topic
  case decode message of
    Just e -> print $ show (e :: Message)
    Nothing -> print $ "Unknown message:" <> show message
