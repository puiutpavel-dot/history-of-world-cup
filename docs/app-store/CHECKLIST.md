# Checklist înainte de „Submit for Review”

| # | Punct (ghidul App Store) | Stare |
|---|---|---|
| 5.2 | Nume, icon, capturi fără FIFA / emblemă / trofeu oficial / sloganuri | ✅ icon = minge pe gazon; fără logouri, crest-uri, poze, imnuri. **Numele: de decis** (vezi METADATA.md) |
| 5.2 | Disclaimer „neoficial, fără legătură cu FIFA” | ✅ în „Despre și setări”, pe web, pe paginile de suport/confidențialitate și în descriere |
| 5.2 | Texte istorice proprii, nu copiate | ✅ rezumate originale (`history.js`); date de meci CC-BY-SA cu atribuire |
| 2.1 | Fără crash, fără butoane moarte / „coming soon” | ✅ quiz fără întrebări nu mai poate porni; ⬜ **test pe iPhone real** (TestFlight) |
| 2.1 | IAP cumpărabil în review, același ID, atașat versiunii | ⬜ în App Store Connect (`com.puiutpavel.historyofworldcup.fullhistory`) |
| 2.1 | Review notes cu drumul spre IAP | ✅ `REVIEW_NOTES.md` |
| 3.1.1 | Deblocare doar prin StoreKit, zero plăți externe | ✅ |
| 3.1.1 | Restore Purchases vizibil | ✅ meniu, „Despre și setări”, ecranul Full History |
| 3.1.1 | Family Sharing pe IAP | ⬜ bifat în App Store Connect (fișierul StoreKit local: da) |
| 2.3.7 | Fără preț în capturi, nume sau subtitlu | ✅ capturile propuse nu au preț; subtitlul nu mai conține „o singură plată” |
| 5.1 | Politică de confidențialitate live, în app și în ASC | ✅ `privacy.html` (GitHub Pages) + link în app; ⬜ URL în ASC |
| 5.1 | Nutrition label | ⬜ „Data Not Collected” în ASC |
| 5.1 | Privacy manifest (UserDefaults, motiv CA92.1) | ✅ `ios/App/Resources/PrivacyInfo.xcprivacy` |
| 5.1 | ATT / Sign in with Apple / ștergere cont | — nu se aplică (fără ads, fără cont) |
| 4.2 | Aplicație nativă, nu site împachetat | ✅ SwiftUI, progres, recorduri, IAP care deblochează conținut |
| 2.5 | Orientare declarată = folosită | ✅ doar portret, doar iPhone |
| — | Export compliance | ✅ `ITSAppUsesNonExemptEncryption = NO` |
| — | Kill + reopen | ✅ cariera și recordurile se salvează la fiecare meci; ⬜ verificat pe telefon |
| — | Account holder | ⬜ contul Apple Developer pe numele tău (persoană fizică) — fără denumiri care sugerează FIFA |

La respingere: răspunde în **Resolution Center**, nu retrimite orb. La 5.2: schimbă numele/asset-urile.
