module Main where

import Control.Monad
import Foreign.Python
import Polysemy

main :: IO ()
main = runFinal $ runPythonIOFinal do
    session \sess -> do
        execute sess "a = 2"
        execute sess "b = 3"
        execute sess "c = a ** b"
        (stdout, stderr) <- execute sess "print(c)"
        embedFinal do
            putStrLn $ "stdout: " ++ stdout
            putStrLn $ "stderr: " ++ stderr
