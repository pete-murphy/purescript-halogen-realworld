module Conduit.Data.Article where

import Prelude

import Conduit.Data.Author (Author, decodeAuthor)
import Conduit.Data.PreciseDateTime (PreciseDateTime)
import Conduit.Data.Username (Username)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Decode (decodeJson, (.:))
import Data.Array (filter)
import Data.Either (Either, isRight)
import Data.Maybe (Maybe)
import Data.Traversable (sequence)
import Slug (Slug)

-- A partial article when we are creating it in the editor

type CreateArticle =
  { title :: String
  , description :: String
  , body :: String
  , tagList :: Maybe (Array String)
  }

-- A partial article when we are creating it in the editor

type UpdateArticle =
  { title :: Maybe String
  , description :: Maybe String
  , body :: Maybe String
  }

-- Next, we'll define our larger article data type that we receive from the server.

type Article =
  { slug :: Slug 
  , title :: String
  , description :: String
  , body :: String
  , tagList :: Array String
  , createdAt :: PreciseDateTime
  , favorited :: Boolean
  , favoritesCount :: Int
  , author :: Author
  }

-- This manual instance is necessary because there is no instance  for an author
-- or datetime; we'll need additional information for decoding than the data type
-- alone, though generic decoding for records is supported.

decodeArticles :: Maybe Username -> Json -> Either String (Array Article)
decodeArticles u json = do
  obj <- decodeJson json 
  arr <- obj .: "articles"
  -- for now, we'll drop out malformed articles
  sequence $ filter isRight $ map (decodeArticle u) arr

decodeArticle :: Maybe Username -> Json -> Either String Article
decodeArticle u json = do
  obj <- decodeJson json
  slug <- obj .: "slug"
  title <- obj .: "title"
  body <- obj .: "body"
  description <- obj .: "description"
  tagList <- obj .: "tagList"
  favorited <- obj .: "favorited"
  favoritesCount <- obj .: "favoritesCount"
  createdAt <- obj .: "createdAt" 
  author <- decodeAuthor u =<< obj .: "author"
  pure { slug, title, body, description, tagList, createdAt, favorited, favoritesCount, author }
