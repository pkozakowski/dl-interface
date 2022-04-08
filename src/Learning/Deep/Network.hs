module Learning.Deep.Network where

import Control.Arrow
import Data.Bicontravariant
import Polysemy
import System.FilePath

class (forall o. Bicontravariant (n o)) => Trainer n where

    type TrainerEffects n :: EffectRow

    init :: Members (TrainerEffects n) r => Sem r (n o i t)
    update :: Members (TrainerEffects n) r => i -> t -> n o i t -> Sem r (n o i t)
    save :: Members (TrainerEffects n) r => FilePath -> n o i t -> Sem r ()
    load :: Members (TrainerEffects n) r => FilePath -> Sem r (n o i t)
    targetToOutput :: n o i t -> t -> o

class ArrowChoice n => Predictor n where

    type PredictorEffects n :: EffectRow

    predict :: Members (PredictorEffects n) r => n i o -> i -> Sem r o

class (Trainer nt, Predictor np) => Network nt np | nt -> np where

    deploy
        :: Members (TrainerEffects nt) r
        => nt o i t -> Sem r (np i o)
