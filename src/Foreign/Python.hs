module Foreign.Python where

import Control.Concurrent
import Control.Monad
import Data.Functor
import GHC.IO.Handle
import Network.MessagePack.Client
import Network.Socket.Free
import Polysemy
import Polysemy.Resource
import System.Process

import Debug.Trace

data PythonSession = PythonSession 
    { processH :: ProcessHandle
    , stdoutH  :: Handle
    , stderrH  :: Handle
    , port     :: Int
    }

data Python m a where
    Execute :: PythonSession -> String -> Python m (String, String)
    NewSession :: Python m PythonSession
    CloseSession :: PythonSession -> Python m ()
    Session :: (PythonSession -> m a) -> Python m a

makeSem ''Python

runPythonIOFinal :: Member (Final IO) r => Sem (Python : r) a -> Sem r a
runPythonIOFinal = resourceToIOFinal . reinterpretH \case
    Execute sess code -> do
        result
           <- embedFinal
            $ execClient "localhost" (port sess)
            $ call "execute" code
        pureT result

    NewSession -> pureT =<< newSession'
    CloseSession sess -> closeSession' sess >> pureT ()

    Session arrow
       -> bracket newSession' closeSession'
        $ bindTSimple arrow <=< pureT
    where
        newSession' :: Member (Final IO) r => Sem r PythonSession
        newSession' = embedFinal do
            port <- getFreePort
            (Nothing, Just stdoutH, Just stderrH, processH)
                <- createProcess
                    (proc "env" ["python3", "python/server.py", show port])
                    { std_out = CreatePipe
                    , std_err = CreatePipe
                    }
            threadDelay 300000
            return PythonSession {..}

        closeSession' :: Member (Final IO) r => PythonSession -> Sem r ()
        closeSession' sess = embedFinal $ cleanupProcess
            ( Nothing
            , Just $ stdoutH sess
            , Just $ stderrH sess
            , processH sess
            )
