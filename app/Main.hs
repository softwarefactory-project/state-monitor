{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TypeOperators #-}

module Main
  ( main,
  )
where

import Data.Maybe
import Data.Text
import Network.MQTT.Client
import Network.MQTT.Topic (mkFilter)
import Network.URI (parseURI)
import Options.Generic
import StateMonitor (newMessage)

data Client w = Client
  { host :: w ::: Maybe Text <?> "The MQTT host",
    topic :: w ::: Maybe Text <?> "The topic"
  }
  deriving (Generic)

instance ParseRecord (Client Wrapped)

deriving instance Show (Client Unwrapped)

main :: IO ()
main = do
  args <- unwrapRecord "Test client"
  let unparsedUri = fromMaybe "mqtt://localhost" $ host args
  let parsedTopic = fromMaybe (error "Invalid Filter") $ mkFilter $ fromMaybe "test/" $ topic args
  let uri = fromMaybe (error $ "Invalid URI: " <> unpack unparsedUri) $ parseURI (unpack unparsedUri)
  mc <- connectURI mqttConfig {_msgCB = SimpleCallback msgReceived} uri
  print =<< subscribe mc [(parsedTopic, subOptions)] []
  waitForClient mc -- wait for the the client to disconnect
  where
    msgReceived _ mtopic msg _ = newMessage mtopic msg
