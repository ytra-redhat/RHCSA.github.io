# Opleverrapport RHCSA EX200 Exam Simulator v3

## 1. Gebruikte bronnen

Deze oplevering is rechtstreeks opgebouwd uit:

- de aangeleverde originele simulator: `RHCSA.github.io.zip`;
- de daarin aanwezige aangepaste questions-set;
- `RHCSA_simulator_requirements_complete_v3(1).md`;
- de geverifieerde GitHub-fork `ytra-redhat/RHCSA.github.io`, standaardbranch `main`.

Er is niet verder gebouwd op een eerdere door AI gegenereerde simulatorversie.

## 2. Vastgestelde hoofdoorzaken

De originele simulator kon de aangeleverde set niet betrouwbaar verwerken door een combinatie van problemen:

1. Het installatiescript verwees nog naar de oorspronkelijke repository.
2. De installer downloadde questions per hoofdstuk met een vaste grens van tien hoofdstukken.
3. CLI, Web UI en installer hadden ieder een eigen hardcoded hoofdstuklijst.
4. Updatechecks gebruikten afwijkende GitHub-URL's en konden daardoor een andere bron gebruiken dan de installatie.
5. Web UI-progress was gebaseerd op bestandsnamen en render-timing, terwijl de CLI een andere voortgangsbron gebruikte.
6. De Web UI-parser kon quoted en meerregelige hints en commando's niet overal betrouwbaar verwerken.
7. De installatie verving bestanden voordat de volledige remote release aantoonbaar was gevalideerd.

## 3. Geïmplementeerde oplossing

### 3.1 Eén exclusieve GitHub-bron

De enige toegestane bron is:

```text
https://github.com/ytra-redhat/RHCSA.github.io
```

Branch:

```text
main
```

De centrale configuratie staat in:

```text
config/repository.env
```

Installer, updater, CLI en Web UI leiden web-, API-, raw- en archive-URL's hiervan af. De releasevalidator weigert:

- een andere repositorywaarde;
- een andere branch;
- een tweede repositorytoewijzing;
- concrete GitHub-codebronnen buiten de eigen fork.

### 3.2 Installatie en herinstallatie

De installer:

1. vraagt via de GitHub API van de eigen fork welke numerieke hoofdstukmappen remote aanwezig zijn;
2. downloadt daarna de volledige `main`-brancharchive van dezelfde fork;
3. vergelijkt de remote hoofdstuklijst met de hoofdstukken in de archive;
4. controleert per hoofdstuk of minimaal één `lab_*.sh` aanwezig is;
5. valideert alle vragen en simulatorcode;
6. bouwt een staging-installatie;
7. behoudt bestaande voortgang;
8. vervangt `/usr/local/share/rhcsa` atomair;
9. herstelt de vorige installatie bij een fout.

Er is geen vaste hoofdstuklus en er worden geen losse questionbestanden uit een andere repository opgehaald.

### 3.3 Dynamische hoofdstukken

Installer, CLI en Web UI gebruiken dezelfde regel:

```text
questions/<numerieke-map>/lab_*.sh
```

Alleen numerieke, niet-lege hoofdstukken worden getoond. Een later toegevoegd hoofdstuk 13 wordt zonder codewijziging meegenomen.

### 3.4 Questions-verwerking

De aangeleverde questions-set is behouden en wordt nu uniform verwerkt:

- 12 hoofdstukken;
- 45 labs per hoofdstuk;
- 540 labs totaal;
- 1.080 taken;
- 540 unieke `LAB_ID`s;
- alle task questions en hints zijn door de Web UI-parser leesbaar;
- single-quoted, double-quoted en meerregelige metadata worden ondersteund;
- alleen `lab_*.sh` wordt als actieve vraag geladen;
- paden, symlinks en path traversal worden geweigerd;
- Web UI task-status wordt via unieke sentinelregels uitgelezen, zodat normale laboutput de status niet kan vervalsen.

### 3.5 Gedeelde voortgang

CLI en Web UI gebruiken één atomair geschreven `progress.json` op basis van `LAB_ID`.

Bestaande oude voortgang op basis van:

- bestandsnaam;
- `hoofdstuk/bestandsnaam`;
- `questions/hoofdstuk/bestandsnaam`;
- absolute oude paden;

wordt gemigreerd naar de stabiele `LAB_ID`.

### 3.6 Automatisch updaten

De geïnstalleerde updater vergelijkt `.version` met de laatste commit op `main` van de eigen fork. Bij een nieuwere commit wordt exact hetzelfde gevalideerde installatieproces uitgevoerd. Een systemd-timer controleert dit ieder uur.

### 3.7 Veiligheidsregels

- `tmux` komt niet voor in actieve questions.
- De installer mag `tmux` als simulatorafhankelijkheid installeren, maar een vraag mag het pakket niet wijzigen.
- Er is geen externe GitHub-fallback voor `ttyd`; alleen goedgekeurde RPM-repositories worden gebruikt.
- De oude installatie blijft bij download-, validatie- of activatiefouten intact.

## 4. Question-set: omvang en moeilijkheid

| Hoofdstuk | Niveau 1 | Niveau 2 | Niveau 3 | Niveau 4 | Niveau 5 |
|---:|---:|---:|---:|---:|---:|
| 1 | 9 | 9 | 9 | 9 | 9 |
| 2 | 9 | 9 | 9 | 9 | 9 |
| 3 | 9 | 9 | 9 | 9 | 9 |
| 4 | 9 | 9 | 9 | 9 | 9 |
| 5 | 9 | 9 | 9 | 9 | 9 |
| 6 | 9 | 9 | 9 | 9 | 9 |
| 7 | 9 | 9 | 9 | 9 | 9 |
| 8 | 9 | 9 | 9 | 9 | 9 |
| 9 | 9 | 9 | 9 | 9 | 9 |
| 10 | 9 | 9 | 9 | 9 | 9 |
| 11 | 9 | 9 | 9 | 9 | 9 |
| 12 | 9 | 9 | 9 | 9 | 9 |

De set heeft daarmee per hoofdstuk een gelijkmatige formele moeilijkheidsverdeling van 9 labs per niveau.

## 5. Uitgevoerde controles

| Controle | Resultaat |
|---|---|
| Dynamische hoofdstukken CLI | PASS — 12 |
| Dynamische hoofdstukken Web UI/backend | PASS — 12 |
| Labs per hoofdstuk | PASS — 45 |
| Totaal labs | PASS — 540 |
| Unieke LAB_ID's | PASS — 540 |
| Bash-syntax alle labs/scripts | PASS |
| Veilig sourcen alle labs | PASS |
| Python-compile | PASS |
| JavaScript-syntax | PASS |
| Alle 540 questions geparseerd | PASS |
| Alle task questions en hints beschikbaar | PASS |
| `tmux` in questions | PASS — 0 |
| Kunstmatige returncode-opdrachten | PASS — 0 |
| Verwijzingen naar oorspronkelijke repository | PASS — 0 |
| Statische tien-hoofdstuklogica in actieve code | PASS — 0 |
| Gesimuleerde schone VM-installatie | PASS — 12 hoofdstukken, 540 labs |
| Gesimuleerde update nieuwere commit | PASS — versie bbbbbbb → ccccccc |

De end-to-end installatietest gebruikte een lokale, gecontroleerde GitHub-responsesimulatie. Daarmee zijn downloadvolgorde, hoofdstukreconciliatie, validatie, staging, activatie en updatepad uitgevoerd zonder de echte VM te wijzigen.

## 6. Gewijzigde bestaande bestanden

- `Install_RHCSA_EX200_Exam_Simulator.sh`
- `RHCSA_EX200_Exam_Simulator/rhcsa`
- `RHCSA_EX200_Exam_Simulator/webui/index.html`
- `RHCSA_EX200_Exam_Simulator/webui/server.py`
- `index.html`
- `readme.md`

## 7. Nieuwe bestanden

- `RHCSA_EX200_Exam_Simulator/docs/DEPLOYMENT_TO_YTRA_FORK.md`
- `RHCSA_EX200_Exam_Simulator/docs/RELEASE_NOTES_V3.md`
- `RHCSA_EX200_Exam_Simulator/docs/RHCSA_simulator_requirements_complete_v3.md`
- `RHCSA_EX200_Exam_Simulator/lib/__init__.py`
- `RHCSA_EX200_Exam_Simulator/lib/progress.py`
- `RHCSA_EX200_Exam_Simulator/objective_titles.json`
- `RHCSA_EX200_Exam_Simulator/scripts/load_repository.sh`
- `RHCSA_EX200_Exam_Simulator/scripts/progressctl.py`
- `RHCSA_EX200_Exam_Simulator/scripts/rhcsa-update`
- `RHCSA_EX200_Exam_Simulator/scripts/validate_release.py`
- `RHCSA_EX200_Exam_Simulator/scripts/validate_release.sh`
- `RHCSA_EX200_Exam_Simulator/systemd/rhcsa-update.service`
- `RHCSA_EX200_Exam_Simulator/systemd/rhcsa-update.timer`
- `config/repository.env`

## 8. Verwijderde bestanden

- Geen bestanden verwijderd.

## 9. Belangrijk vóór installatie

De installer installeert bewust de volledige remote `main`-branch en niet de lokaal via rsync/scp gekopieerde code. Daarom moet deze oplevering eerst in `ytra-redhat/RHCSA.github.io` op `main` worden gepubliceerd. Zolang de oude installer op GitHub blijft staan, zal een VM-installatie ook de oude code blijven ophalen.

Zie:

```text
RHCSA_EX200_Exam_Simulator/docs/DEPLOYMENT_TO_YTRA_FORK.md
```

## 10. Concrete verbeteringsvoorstellen — niet doorgevoerd

Conform de requirement zijn onderstaande inhoudelijke verbeteringen alleen geïnventariseerd.

### Voorstel A — markers doelgerichter toepassen

Alle **540 labs** bevatten momenteel een markerframework. Markers zijn vooral nodig bij state-reversal, zoals installeren → verwijderen of enable → disable. Voor labs met twee onafhankelijke artifacts kunnen blijvende markers juist oude resultaten meenemen naar een nieuwe poging.

**Voorstel:** classificeer labs in `state`, `output`, `artifact` en `state-reversal`; gebruik blijvende markers alleen voor state-reversal of expliciete persistente voortgang.

### Voorstel B — validators inhoudelijk versterken

Een conservatieve statische scan markeert **495 van 1080 taken** voor handmatige review omdat de live validator voornamelijk op bestaan of niet-leeg zijn van een artifact lijkt te steunen. Dit is geen bewezen fout per taak, maar wel een duidelijke reviewqueue voor false positives.

**Voorstel:** per gemarkeerde taak inhoud, eigenaar, rechten, exacte output of systeemtoestand controleren en negatieve testcases toevoegen.

### Voorstel C — meer inhoudelijke variatie

De 540 labs hebben **300 unieke hoofdtitels**; **240 titelinstanties** herhalen een titel op een ander vraagnummer of niveau.

**Voorstel:** herhaalde sjablonen vervangen door troubleshooting-, herstel-, gecombineerde-objective- en exam-trapvarianten, zonder het aantal labs te verkleinen.

### Voorstel D — live RHEL 10 testmatrix

De statische en gesimuleerde installatietests zijn geslaagd, maar niet iedere systeemveranderende lab is op een verse RHEL 10-VM uitgevoerd.

**Voorstel:** geautomatiseerde snapshots en een testmatrix voor storage, networking, SELinux, Flatpak, systemd en bootloader, met per lab `prepare → execute reference → check → cleanup → restore snapshot`.

### Voorstel E — publieke theoriepagina dynamiseren

De simulator zelf is dynamisch. De losse top-level documentatiewebsite bevat nog handmatig onderhouden theorieblokken voor de kernhoofdstukken.

**Voorstel:** genereer ook die navigatie tijdens de releasebuild uit een catalogus. Dit is niet nodig voor de werking van CLI/Web UI en is daarom niet stilzwijgend gewijzigd.

### Voorstel F — release-integriteit

**Voorstel:** publiceer releases met een ondertekende manifest/checksum en laat de installer desgewenst een tag of commit-SHA pinnen. Nu wordt bewust de laatste commit op `main` gebruikt, overeenkomstig de huidige requirement.

## 11. Conclusie

De simulatorcode is aangepast aan de volledige aangeleverde questions-set en de expliciete projectrequirements. Installatie, herinstallatie en updates gebruiken uitsluitend de eigen fork, hoofdstukken worden dynamisch bepaald en alle 540 labs worden door CLI en Web UI ingelezen. De genoemde inhoudelijke verbeteringen zijn niet toegepast en wachten op goedkeuring.
