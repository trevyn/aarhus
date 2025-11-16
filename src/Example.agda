{-# OPTIONS --cubical #-}

module Example where

open import Cubical.Foundations.Prelude
open import Cubical.Data.Nat

-- Simple example with a hole
addTwo : ℕ → ℕ
addTwo n = {! !}

-- Path example using cubical features
pathExample : (A : Type) → (x : A) → x ≡ x
pathExample A x = {! !}

-- Function composition with holes
compExample : {A B C : Type} → (B → C) → (A → B) → A → C
compExample g f x = {! !}

-- Dependent pair example
pairExample : (A : Type) → (B : A → Type) → (a : A) → B a → Σ A B
pairExample A B a b = {! !}
