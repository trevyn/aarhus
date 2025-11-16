{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Monad (forM_)
import           Data.List (isPrefixOf)
import           Options.Applicative
import           System.IO

-- Command line options
data Options = Options
  { inputFile :: FilePath
  , verbose   :: Bool
  } deriving (Show)

optionsParser :: Parser Options
optionsParser = Options
  <$> argument str
      ( metavar "FILE"
     <> help "Agda file to analyze" )
  <*> switch
      ( long "verbose"
     <> short 'v'
     <> help "Enable verbose output" )

-- Main entry point
main :: IO ()
main = do
  hSetEncoding stdout utf8
  opts <- execParser $ info (optionsParser <**> helper)
    ( fullDesc
   <> progDesc "Query holes in Agda files"
   <> header "agda-holes - a CLI tool for Agda hole inspection" )

  runHoleQuery opts

-- Run the hole query
runHoleQuery :: Options -> IO ()
runHoleQuery opts = do
  handle <- openFile (inputFile opts) ReadMode
  hSetEncoding handle utf8
  content <- hGetContents handle
  let linesWithNumbers = zip [1..] (lines content)
  let holes = findHoles linesWithNumbers
  displayHoles holes (verbose opts)
  hClose handle

-- Information about a hole
data HoleInfo = HoleInfo
  { holeLineNum  :: Int
  , holeColumn   :: Int
  , holeLine     :: String
  , holeContent  :: String
  } deriving (Show)

-- Find all holes in the file
findHoles :: [(Int, String)] -> [HoleInfo]
findHoles linesWithNums = concatMap findInLine linesWithNums
  where
    findInLine (lineNum, line) = map (mkHoleInfo lineNum line) (findHolePositions line)
    mkHoleInfo lineNum line (col, content) = HoleInfo lineNum col line content

-- Find positions of holes in a line
findHolePositions :: String -> [(Int, String)]
findHolePositions = go 0
  where
    go _ [] = []
    go pos ('{':'!':rest) =
      let (inside, after) = span (/= '!') rest
      in case after of
           ('!':'}':remaining) -> (pos + 1, inside) : go (pos + length inside + 4) remaining
           _ -> go (pos + 2) rest
    go pos (_:rest) = go (pos + 1) rest

-- Display holes
displayHoles :: [HoleInfo] -> Bool -> IO ()
displayHoles [] _ = putStrLn "No holes found."
displayHoles holes verboseMode = do
  putStrLn $ "Found " ++ show (length holes) ++ " hole(s):\n"
  forM_ (zip [1..] holes) $ \(idx, hole) -> do
    putStrLn $ "Hole #" ++ show idx
    putStrLn $ "  Position: Line " ++ show (holeLineNum hole) ++ ", Column " ++ show (holeColumn hole)
    if null (holeContent hole)
      then putStrLn "  Content: {!!} (empty hole)"
      else putStrLn $ "  Content: {!" ++ holeContent hole ++ "!}"
    when verboseMode $ do
      putStrLn $ "  Context: " ++ trim (holeLine hole)
    putStrLn ""
  where
    when True action = action
    when False _ = return ()
    trim = dropWhile (== ' ')
