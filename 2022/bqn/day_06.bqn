# •Show 4 + ⊐⟜1 ⍷⊸≡¨ <˘ 4↕ •FChars "../day_06.txt"
# •Show 14 + ⊐⟜1 ⍷⊸≡¨ <˘ 14↕ •FChars "../day_06.txt"

n ← 4
input ← •FChars "../day_06.txt"
windows ← n ↕ input
uniq ← ⍷⊸≡˘ windows
index ← uniq ⊐ 1
•Show n + index

# PktN←{𝕨+⊑1⊐˜(∧´∊)˘𝕨↕𝕩}
