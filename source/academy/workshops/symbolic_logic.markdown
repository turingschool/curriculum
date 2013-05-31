---
layout: page
title: SymbolicLogic
---

When translating from English sentences into logical form, "but"
generally means the same as "and", and the phrase "neither A nor B" is
translated as "not A and not B".  Additionally, ¬ (negation) is
performed before logical AND and logical OR, and all operations within
parenthesis are performed first. (The precedence rules that apply are
very similar to those in algebra.)

Using the sentence variables (p, q, and r) and the logic symbols
- ¬ (unicode: U+00AC)
- ⋀ (unicode: U+22C0)
- ⋁ (unicode: U+22C1)
rewrite the following symbolically.

Q: I can study and go to parties every night.
A: P ⋀ Q

Q: I am hungry but not thirsty.
A: P ⋀ ¬Q

Q: The baby is either hungry or thirsty.
A: P ⋁ Q

Q: The weather is neither hot nor cold.
A:
  1. (¬P) ⋀ (¬Q)
  2. ¬(P ⋁ Q)

Q: I can study hard, or I can go to parties, but I cannot study hard and go
to parties.
A: (P ⋁ Q) ⋀ ¬(P ⋀ Q)
