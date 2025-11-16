module example where

data ℕ : Set where
  zero : ℕ
  suc  : ℕ → ℕ

_+_ : ℕ → ℕ → ℕ
zero + n = n
suc m + n = suc (m + n)

data List (A : Set) : Set where
  []  : List A
  _∷_ : A → List A → List A

-- Function with a hole
length : {A : Set} → List A → ℕ
length [] = zero
length (x ∷ xs) = {!!}

-- Another function with holes
map : {A B : Set} → (A → B) → List A → List B
map f [] = {!!}
map f (x ∷ xs) = {!!}

-- A proof with a hole
+-comm : (m n : ℕ) → m + n ≡ n + m
+-comm m n = {!!}
  where
    data _≡_ {A : Set} (x : A) : A → Set where
      refl : x ≡ x
