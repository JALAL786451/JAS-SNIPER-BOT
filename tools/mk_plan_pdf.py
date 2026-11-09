from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.units import cm
OUT='/home/user/JAS-SNIPER-BOT/docs/pdf/JAS_FTMO_Plan_Monday.pdf'
TXT='/home/user/JAS-SNIPER-BOT/docs/pdf/JAS_FTMO_Plan_Monday.txt'
ss=getSampleStyleSheet()
H1=ParagraphStyle('h1',parent=ss['Heading1'],textColor=colors.HexColor('#0b3d6b'),spaceAfter=6,keepWithNext=1)
H2=ParagraphStyle('h2',parent=ss['Heading2'],textColor=colors.HexColor('#1f6f43'),spaceBefore=8,spaceAfter=4,keepWithNext=1)
N=ParagraphStyle('n',parent=ss['Normal'],fontSize=9.5,leading=13)
S=ParagraphStyle('s',parent=N,fontSize=8.5,leading=11)
TS=ParagraphStyle('t',parent=N,fontSize=8.5,leading=10.5)
story=[]; txt=[]
def h1(t): story.append(Paragraph(t,H1)); txt.append('\n'+'='*70+'\n'+t+'\n'+'='*70)
def h2(t): story.append(Paragraph(t,H2)); txt.append('\n--- '+t+' ---')
def p(t,st=N): story.append(Paragraph(t,st)); txt.append(t.replace('<b>','').replace('</b>','').replace('<i>','').replace('</i>',''))
def bl(items):
    for i in items: p('&bull; '+i)
def tb(rows,w=None):
    clean=lambda x:x.replace('<b>','').replace('</b>','')
    story.append(Table([[Paragraph(c,TS) for c in r] for r in rows],colWidths=w,repeatRows=1,
        style=TableStyle([('BACKGROUND',(0,0),(-1,0),colors.HexColor('#0b3d6b')),('TEXTCOLOR',(0,0),(-1,0),colors.white),
        ('GRID',(0,0),(-1,-1),0.4,colors.grey),('VALIGN',(0,0),(-1,-1),'TOP'),
        ('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.white,colors.HexColor('#eef4fa')])])))
    story.append(Spacer(1,6))
    for r in rows: txt.append(' | '.join(clean(c) for c in r))

story.append(Paragraph('JAS SNIPER - FTMO Plan + Data Guide',ParagraphStyle('T',parent=ss['Title'],textColor=colors.HexColor('#0b3d6b'))))
p('Jalal ke liye | 6 Nov 2026 (9 Nov: Monday list + Tokri 55/20 add) | Monday (9 Nov) se milkar kaam. Hamesha: backtest -> demo -> live.',S)
txt.insert(0,'JAS SNIPER - FTMO Plan + Data Guide\n6 Nov 2026')

h1('1. Abhi ka haal (6 Nov)')
tb([['Account','Haal'],
 ['474832446 FTMO demo','Balance 98,909.17, equity 99,011. Khuli: i6 US500 BUY 2.81, t5 XAU 0.03, XAG 0.02 (kul +101.83). USTEC SL -994 (-1R) - qaide ke mutabiq. Target baqi 10,989, aaj farsh 95,903.'],
 ['472716649 demo','2,153.25, 0 khuli (c1 US500).'],
 ['253687618 LIVE cent','~37,865 USC, manual fishing; koi trade-EA nahi (sirf JasMauqa m7.3 madadgar).']],[4*cm,13*cm])
h2('EA ke nateeje (backtest IMTIHAN 2019-2026, kharche ke baad)')
tb([['EA','Trades','Expectancy','Jeet'],
 ['t5 JasTrend 4H (XAU XAG US500 USTEC) 0.75%','641','+0.208R','-'],
 ['i6 IBS US500 1%','190','+0.082R','~70%'],
 ['i6 IBS USTEC 1%','207','+0.071R','71%'],
 ['k2 Khirki 7 index 0.15%','505','+0.075R','64%']],[8*cm,2*cm,3*cm,2*cm])
p('<b>FTMO sim #68 (94 challenge 2019-26):</b> 83 pass / 0 fail / 11 adhoore, median ~11 mahine. 3 mahine 0%, 6 mahine 6%, 12 mahine ~51%, 24 mahine ~73%. '
  '<b>#101</b> (+ Kachhua 12 @0.25%): 85/0, median 10.2. <b>#100</b>: Trend akela (81/0, 17.4) > Tide akela (67/0, 22.1).')
p('<b>Tokri (fishing) sim tk2:</b> gold H1 2005-26, $1000, 240 variant - sab account khatam (M1 2009-18 bhi). EA ke liye nahi.')

h1('2. Data - kya hai, kya chahiye')
h2('Repo mein mojood')
tb([['Qism','Instrument (kab se)'],
 ['H1 Dukascopy','Gold/Silver 2003+, US500/USTEC 2012+ (2012-17 patla), DE30/US30 2013+, UK100/FR40/ES35 2012+, STOXX50/JP225/HK50/CH20 2011-12+, AUS200 2013+, China50 2017+, US2000 2019+, WTI/Brent 2013+, Cocoa/Coffee/Cotton/Soy/DXY 2017+, BTC 2017+'],
 ['M1','Gold 2009-2018 (histdata), 2015 + 2021-24 (QDM); US500/USTEC 2012-18 + 2021-26 (QDM)'],
 ['Daily','BTC Bitstamp']],[3*cm,14*cm])
h2('GAYAB - Monday tak download (tarteeb se)')
tb([['#','Kya','Kahan se','Kyun'],
 ['1','Gold XAUUSD M1 2019, 2020, 2025, 2026 (BID + ASK)','Dukascopy (QDM / JAS_M1ZIP.bat)','14+ saal M1 poora'],
 ['2','US500 + USTEC M1 2019, 2020 (BID + ASK)','Dukascopy (QDM)','IBS/Pre-FOMC'],
 ['3','Index daily lambi history: ^GSPC ^NDX ^GDAXI ^FTSE ^FCHI ^STOXX50E ^N225 ^HSI ^AXJO','Yahoo Finance / Stooq','TALAASH 2000 se pehle'],
 ['4','Copper, NatGas, Platinum H1 (agar mile)','Dukascopy','Kachhua tokri'],
 ['5','US 10y yield (DGS10), TLT/IEF daily, VIX','FRED + Yahoo','B3 rebalancing, B6 vol'],
 ['6','FOMC tareekhein 1994-2026','federalreserve.gov','B1 Pre-FOMC'],
 ['7','Exchange chutti list (DE, UK, JP, HK, AU)','exchange sites','B2 chutti non-US']],[0.7*cm,6.5*cm,4.5*cm,5.3*cm])
h2('Data sites (free pehle)')
tb([['Site','Kya milta','Note'],
 ['<b>Dukascopy</b> (free) - QuantDataManager / Tickstory / dukascopy-node','Tick/M1/H1: XAU/XAG 2003+, USA500 2012+, USATECH/USA30/DEU/GBR/FRA/JPN 2013+, HKG 2013-06, EUS/AUS 2014-06, US2000 2018-08; oil/gas/copper','<b>BEHTAREEN.</b> BID+ASK alag, UTC. Saare gap yahan se.'],
 ['<b>HistData.com</b> (free)','M1 bid, gold 2018 ke baad bhi','EST bina DST. Cross-check ke liye.'],
 ['<b>Stooq</b> (free) stooq.com/db/h/','Daily bulk zip, index + commodity','Rozana quota.'],
 ['<b>Yahoo Finance</b> (free)','Daily index (purani history), futures GC=F CL=F ~2000+','Futures roll adjusted nahi.'],
 ['<b>FRED</b> (free)','DGS10, DFII10, VIX','Sirf macro.'],
 ['FirstRate Data (~$299)','1-min futures 2007+','Abhi ZAROORAT NAHI.']],[5.5*cm,6.5*cm,5*cm])
h2('Download qaide (taake Claude seedha parh sake)')
bl(['Har file ka naam: SYMBOL_TF_SAAL (misaal XAUUSD_M1_2019.zip). CSV: Date, Time, Open, High, Low, Close, Volume.',
    'Timezone likh dein (UTC ya GMT+2). BID aur ASK alag file.',
    'Repo mein: data/qdm/M1/ (M1), data/duka/H1/ (H1), data/daily/ (Yahoo/Stooq), data/macro/ (FRED). Phir GitHub par push ya Claude ko bata dein.',
    'Ek file 100 MB se bari ho to zip karein ya saal-saal tod dein (GitHub hadd).'])

h1('3. Research tasdeeq (agent, 6 Nov)')
p('Aam sabaq (McLean & Pontiff 2016): research chhapne ke baad faida ~1/3 kam hota hai. Paper ke number ka 1/2 - 2/3 umeed rakhein.')
tb([['Hamara idea','Saboot','Khulasa'],
 ['JasTrend 4H','<b>Mazboot</b>','AQR (Hurst/Ooi/Pedersen 2017): 1880 se 67 market. 2009 baad thoda kamzor.'],
 ['IBS','Darmiyana','Pagonidis; 2015-16 manfi; 2023 research tasdeeq. Ghatne ka khatra.'],
 ['Khirki','Darmiyana','Raat ka faida duniya ke index mein (Liu & Tse 2017). Kharcha khatra.'],
 ['Kachhua','Darmiyana','Trend family; commodity trend 2009 baad kamzor.'],
 ['Chutti se pehle','Kamzor','1990 baad asar kam (Ko 2021). ~9 trade/saal, risk chhota.']],[3.5*cm,2.5*cm,11*cm])

h1('4. Nayi strategies (test sirf discuss ke BAAD)')
tb([['#','Strategy','Qaida (khaka)','Saboot / khatra'],
 ['B1','Pre-FOMC drift (US500, USTEC)','FOMC se ek din pehle close BUY -> FOMC din close band. 8/saal.','Lucca & Moench 2015; 2016 baad kamzor. Sample chhota.'],
 ['B2','Chutti se pehle non-US (DE30 UK100 JP225 HK50 AUS200)','#59 jaisa, har exchange ki chutti.','Kim & Park 1994. Code tayyar = sasta test.'],
 ['B3','Mahine-aakhir rebalancing (US500)','MTD stocks >> bonds -> aakhri 3-5 din SELL, warna BUY; naye mahine pehle din band.','Harvey et al. 2025. Trend se alag. 12/saal.'],
 ['B4','BTC/ETH trend','Daily/4H Supertrend ya breakout, SL ATR.','Liu & Tsyvinski 2021. FTMO crypto spread dekho.'],
 ['B5','Gold raat hold','US close BUY -> COMEX open band.','Blose et al.; asar kamzor, spread khatra.'],
 ['B6','Volatility sizing','Zyada hilne par lot chhota (hadd ke ANDAR).','Mixed; DD kam karta hai.'],
 ['B7','Aakhri 30 min momentum','M1/M5 chahiye.','Baltussen 2021; kharcha bhaari - aakhir mein.']],[0.8*cm,4*cm,6.2*cm,6*cm])
p('<b>Na karein:</b> gold vs real yield (2022 baad toota), BTC din-e-hafta (random jaisa), grid/martingale/hedge/averaging (EA qaida), forex (aap ne band kiya).',S)

story.append(PageBreak())
h1('5. FTMO PLAN - Monday se')
p('Maqsad: asli FTMO challenge sirf tab jab demo + sim dono saaf hon. Koi risk hadd (risk %, din 4%, kul hadd) khud se NAHI barhayi jayegi.')
h2('Hafta 1 (9-13 Nov): data + faisle - koi faltu test nahi')
bl(['<b>Mon:</b> aap data push karein -> Claude sirf jaanch kare (gap, timezone, BID/ASK). Koi naya test nahi.',
    '<b>Mon:</b> FTMO demo 474832446 ka SS (sec 0 update). Hafte mein 2 SS kaafi (Mon + Jumma).',
    '<b>Discuss (aap faisla):</b> (a) Kachhua e1 0.25% demo par #68 ke saath? (b) B1 aur B2 mein se kaun pehle? (c) FTMO swap-free email bheji / jawab?',
    '<b>Qaida pehle:</b> jo strategy chuni, us ka qaida TEST SE PEHLE likha jaye (TALAASH 2012-18 / IMTIHAN 2019+ ek dafa, PASS shart pehle se).'])
h2('Monday 9 Nov - kaam ki list (haal 9 Nov)')
tb([['#','Kaam','Haal'],
    ['1','Data jaanch: US500 + USTEC M1 2019-20 (QDM)','HUA - saaf (49vi chat)'],
    ['2','Data jaanch: gold M1 2019/20/25/26 (data/qdm/M1)','repo mein hai - jaanch baqi'],
    ['3','FTMO demo 474832446 SS','HUA - equity 99,559, 3 khuli +649.90'],
    ['4','PC Claude + TV Bridge (izafi kaam): JAS Naqsha+5EA j3.2 TV par','HUA - 0 error, chart par'],
    ['5','Tokri EA tk2 "perfect": F7 (0 error) -> demo 472716649 (USD) par chalao, LIVE NAHI; Q22 sawal tay (kitne $ ulta par bhari taraf badle)','baqi'],
    ['6','NAYA: Tokri + Turtle 55/20 test - rukh = 55 din ki high toot BUY / low toot SELL; 20 din ki ulti toot = rukh khatam. Rukh taraf 0.02, doosri 0.01, baqi tk2 qaide. Gold H1/M1, $1000, kharche ke saath','baqi - qaida pehle likha jaye, phir test'],
    ['7','LIVE report se aap ka ASLI tareeqa nikaalna (naqsha, test nahi)','baqi'],
    ['8','Discuss (a)(b)(c) upar wale','baqi']],[0.8*cm,11.5*cm,4.7*cm])
h2('Hafta 2 (16-20 Nov): ek strategy ka test + judge')
bl(['Chuni strategy: TALAASH -> PASS ho to IMTIHAN ek dafa.',
    '<b>Judge agent</b> (aap ki ijazat se): alag code se wahi nateeja dobara - CLEAN ho tab hi maana jaye.',
    'PASS -> FTMO sim (#68 + nayi) - fail 0 rahe aur pass/median behtar ho tab jor.',
    'FAIL -> band, wahi idea dobara tweak nahi (qismat ka jaal).'])
h2('Hafta 3-4 (23 Nov - 4 Dec): demo + asli FTMO ki tayyari')
bl(['Naya EA (agar PASS) pehle Exness demo par, F7 + Tester milaan.',
    '<b>Black Friday (~26-30 Nov):</b> ftmo.com checkout par asli offer dekhein (pichle saal ~20% chhoot). Paise sirf ftmo.com par; code tab jab qeemat waqai kam ho.',
    'Asli FTMO se PEHLE checklist (neeche) poori ho.'])
h2('Asli FTMO se pehle CHECKLIST')
tb([['#','Kaam','Haal'],
 ['1','t5/i6 InpServerGMT = FTMO server (-2 ya jo ho)','baqi'],
 ['2','FTMO symbol naam (US500.cash, GER40.cash, XAUUSD...) EA inputs mein','baqi'],
 ['3','FTMO support se likhwana: weekend/gap holding (IBS Jumma 16:15 NY) jaiz?','baqi'],
 ['4','Swing account chunna (weekend hold)','baqi'],
 ['5','Swap-free email (har stage par, trade se pehle)','aap ne bheji - jawab?'],
 ['6','VPS (~$10-15/mahina) - MT5 24 ghante','baqi'],
 ['7','Pehra: target 110k, din 4% farsh, kul hadd band','EA mein hai'],
 ['8','Demo par kam se kam kuch hafte bina ghalti','chal raha']],[0.8*cm,12*cm,4.2*cm])
h2('Sach - umeed kitni rakhein')
bl(['Sim mein fail 0 hai, magar pass hone ka median ~10-11 mahine. 3 mahine mein pass ka imkaan ~0%. Jaldi pass ke liye risk barhana = fail ka khatra (0.50% Kachhua par 8 fail).',
    '"Extraordinary" nateeja waada nahi - sirf imaandar test. Jo PASS ho, wahi lagega; FAIL wala band.',
    'Har naya jor / trade barhana / FTMO pass par: docs/bank.md (#59, #69, #76) yaad.'])
h2('Milkar kaam ka tareeqa')
bl(['Har test: pehle aap se discuss -> qaida likha -> test -> judge -> faisla aap ka.',
    'Agent/judge sirf jab aap naam le kar kahein, aur hafte ki limit 50% se kam ho.',
    'Nayi chat: "TRADING" likhein. Chat lambi ho to "chat khatam".'])

h1('6. PDF / file kaise kholein (free)')
bl(['<b>Sab se asaan (install nahi):</b> PDF par right-click -> Open with -> Microsoft Edge ya Google Chrome.',
    '<b>Free PDF reader:</b> SumatraPDF - www.sumatrapdfreader.org (halka, free, bina ads). Ya Adobe Acrobat Reader (get.adobe.com/reader, free).',
    '<b>Notepad:</b> PDF Notepad mein theek nahi khulti - is liye isi ka .txt version bhi saath hai (JAS_FTMO_Plan_Monday.txt).'])
doc=SimpleDocTemplate(OUT,pagesize=A4,leftMargin=1.8*cm,rightMargin=1.8*cm,topMargin=1.5*cm,bottomMargin=1.5*cm,title='JAS FTMO Plan + Data Guide',author='Claude for Jalal')
def foot(c,d):
    c.setFont('Helvetica',7.5); c.setFillColor(colors.grey); c.drawString(1.8*cm,0.9*cm,'JAS SNIPER | FTMO plan + data | 6 Nov 2026'); c.drawRightString(A4[0]-1.8*cm,0.9*cm,'Safha %d'%d.page)
doc.build(story,onFirstPage=foot,onLaterPages=foot)
import re
open(TXT,'w',encoding='utf-8').write(re.sub(r'&bull;','-',re.sub(r'<[^>]+>','','\n'.join(txt)))+'\n')
print('ok')
