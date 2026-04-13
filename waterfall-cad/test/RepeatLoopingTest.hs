module Main (main) where

import System.Exit (exitFailure, exitSuccess)
import Linear (V2(..))
import qualified Waterfall.TwoD.Path2D as Path2D

-- | Build a regular polygon edge from angle 0 to angle (2*pi/n) on a unit circle,
-- then use repeatLooping to tile it around the full circle.
-- splitPath should return exactly n segments, not n+1.
makeRegularPolygonEdge :: Int -> Path2D.Path2D
makeRegularPolygonEdge n =
    let angle = 2 * pi / fromIntegral n
        start = V2 1 0
        end = V2 (cos angle) (sin angle)
    in Path2D.line2D start end

assertEqual :: (Eq a, Show a) => String -> a -> a -> IO Bool
assertEqual label expected actual =
    if expected == actual
        then do
            putStrLn $ "  PASS: " ++ label
            return True
        else do
            putStrLn $ "  FAIL: " ++ label
            putStrLn $ "    expected: " ++ show expected
            putStrLn $ "    actual:   " ++ show actual
            return False

main :: IO ()
main = do
    putStrLn "repeatLooping tests:"

    results <- sequence
        [ testSegmentCount 3 -- triangle
        , testSegmentCount 4 -- square
        , testSegmentCount 6 -- hexagon
        , testSegmentCount 8 -- octagon (gear-like)
        ]

    if and results
        then putStrLn "All tests passed." >> exitSuccess
        else putStrLn "Some tests FAILED." >> exitFailure

testSegmentCount :: Int -> IO Bool
testSegmentCount n = do
    let edge = makeRegularPolygonEdge n
        looped = Path2D.repeatLooping edge
        segments = Path2D.splitPath2D looped
    assertEqual
        ("regular " ++ show n ++ "-gon: splitPath gives " ++ show n ++ " segments")
        n
        (length segments)
