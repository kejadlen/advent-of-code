Split ⇐ {𝕩⊔˜(⊢-˜+`×¬)0=≠¨𝕩}
Transpose ⇐ =⊸{<⎉𝕨⍉⍟𝕨>𝕩}
OnlyCrates ⇐ ∊⟜('A'+↕26)⊸/
RejectEmpty ⇐ {((≠¨𝕩) > 0) / 𝕩}

⟨stacks, moves⟩ ← Split •Flines "../day_05.txt"
stacks ↩ RejectEmpty OnlyCrates¨ Transpose stacks
•Show stacks
