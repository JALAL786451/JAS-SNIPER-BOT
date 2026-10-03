# Nayi file lagane ki list

Har dafa **poori** list. Koi qadam na chhorein — 27-28 September ko kai ghante
isi liye zaya hue ke main har dafa ek qadam bhool jata tha.

---

## Pehle: purani basket band karni hai?

Agar naye qaidon ka saaf natija chahiye, to pehle:

- [ ] **1.** `Algo Trading` **BAND** karein (laal)
- [ ] **2.** Saari khuli lots **close** karein
- [ ] **3.** Phir aage barhein

Sirf panel ki likhai badal rahi ho to ye zarurat nahi — khuli lots band nahi hongi.

---

## File lena

- [ ] **4.** Browser mein raw link kholein
- [ ] **5.** **Ctrl + F5** (zabardasti taza — warna purana safha milta hai)
- [ ] **6.** Sab se upar **`BUILD ...`** parh lein. Jo number mujhe bheja, wohi hona chahiye
- [ ] **7.** **Ctrl + A** phir **Ctrl + C**

## File daalna

- [ ] **8.** MetaEditor agar khula hai to **poora band** kar dein
      *(do tabs ek hi naam ki khul jati hain, aur F7 galat wali compile kar deta hai)*
- [ ] **9.** MT5 -> **Navigator** -> `Expert Advisors` -> EA ke naam par **right-click** -> **`Modify`**
      *(**kabhi** `File -> New` se nayi file na banayein)*
- [ ] **10.** Code par click -> **Ctrl + A** -> **Ctrl + V**
- [ ] **11.** **Ctrl + Home** -> pehli line par **`BUILD ...`** dekh lein
- [ ] **12.** **Ctrl + S**
- [ ] **13.** **F7**
- [ ] **14.** Neeche `0 errors, 0 warnings` aur `code generated` parh lein

## Chart par lagana

- [ ] **15.** MT5 -> chart par **right-click** -> `Expert Advisors` -> **`Remove`**
- [ ] **16.** Navigator se EA ko chart par **drag** karein
- [ ] **17.** **`Common`** tab -> **`Allow Algo Trading`** par **TICK**   <-- ye aksar chhoot jata hai
- [ ] **18.** **`Inputs`** tab -> **`Reset`**   <-- warna purani values chipki rehti hain
- [ ] **19.** **OK**
- [ ] **20.** Toolbar ka **`Algo Trading`** button **HARA** hona chahiye   <-- ye bhi aksar chhoot jata hai

## Aakhir mein check

- [ ] **21.** Chart ke upar dayein kone mein icon **BLUE** hai (grey nahi)
- [ ] **22.** Panel ki pehli line par **wohi BUILD number** hai jo bheja gaya tha
- [ ] **23.** Panel ki aakhri line parh lein: `Sab saaf` ya `Ruka hua: ...`

---

## Kuch theek na ho to

| Nishani | Matlab | Hal |
|---|---|---|
| Icon **grey** | EA ko trade ki ijazat nahi | Qadam **17** aur **20** — dono check karein |
| Panel par **purana BUILD** | Chalne wala code purana hai | Neeche wali tareekh wali jaanch |
| Browser par purana BUILD | Safha purana hai | **Ctrl + F5** |
| Panel par likhai **jami hui** | EA chal hi nahi raha | EA hata kar dobara lagayein |
| Setting badli hui nazar aaye | Purani values bachi hain | Qadam **18** (Reset) |

### Tareekh wali jaanch — jab panel par purana BUILD ho

MT5 -> `File` -> `Open Data Folder` -> `MQL5` -> `Experts` -> **Date modified** dekhein:

- **MQL5 Source File** nayi, **MQL5 Program** purani
  -> compile kisi **aur** file ka hua. Qadam **8** se dobara shuru karein.
- **dono nayi**, phir bhi panel purana
  -> EA reload nahi hua. Qadam **15** se dobara.
