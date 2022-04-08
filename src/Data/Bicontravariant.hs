module Data.Bicontravariant where

class Bicontravariant f where

    bicontramap :: (b -> a) -> (d -> c) -> f a c -> f b d
    bicontramap f g = contrafirst f . contrasecond g

    contrafirst :: (b -> a) -> f a c -> f b c
    contrafirst f = bicontramap f id

    contrasecond :: (c -> b) -> f a b -> f a c
    contrasecond = bicontramap id
