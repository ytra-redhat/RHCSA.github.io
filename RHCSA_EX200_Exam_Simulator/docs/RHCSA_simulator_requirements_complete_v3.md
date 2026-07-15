# Requirements RHCSA EX200 Exam Simulator v3

## 1. Doel en scope

De RHCSA EX200 Exam Simulator moet worden doorontwikkeld tot een stabiel, uniform, onderhoudbaar, veilig en volledig oefenplatform voor RHCSA v10, met aanvullende bonushoofdstukken voor relevante RHCSA v9-onderwerpen.

De simulator moet examengericht zijn. Opdrachten moeten zoveel mogelijk overeenkomen met praktische RHCSA-examenopdrachten en mogen geen kunstmatige handelingen vereisen die een kandidaat tijdens een echt examen normaal gesproken niet zou uitvoeren.

CLI en Web UI moeten:

- dezelfde vragen tonen;
- dezelfde vraagstructuur gebruiken;
- dezelfde hints tonen;
- dezelfde voortgangsbron gebruiken;
- dezelfde validatieresultaten tonen;
- dezelfde `LAB_ID` als primaire sleutel gebruiken;
- consistent blijven na het toevoegen, vervangen, verplaatsen of verwijderen van vragen.

Installatie, herinstallatie en updates mogen uitsluitend gebruikmaken van de eigen GitHub-repository:

```text
ytra-redhat/RHCSA.github.io
```

De oorspronkelijke repository of een upstream fork mag nergens meer als bron, fallback of alternatieve updatebron worden gebruikt.

---

## 2. Bronrepository en repository-onafhankelijkheid

### 2.1 Enige toegestane bron

De volledige simulator, installer, vragen, Web UI-assets, CLI-code, documentatie en updates moeten uitsluitend worden opgehaald uit:

```text
https://github.com/ytra-redhat/RHCSA.github.io
```

De standaardbranch is:

```text
main
```

### 2.2 Centrale configuratie

Er moet exact één centrale repositoryconfiguratie bestaan, bijvoorbeeld:

```bash
RHCSA_GITHUB_REPOSITORY="ytra-redhat/RHCSA.github.io"
RHCSA_GITHUB_BRANCH="main"
```

Alle overige GitHub-locaties moeten hiervan worden afgeleid, waaronder:

- Git clone URL;
- raw-content-URL;
- GitHub API-URL;
- brancharchive-URL;
- installer-URL;
- questions-URL;
- update-URL;
- Web UI-links;
- documentatielinks.

Geen enkel ander shellscript, Python-bestand, JavaScript-bestand, HTML-bestand, configuratiebestand of document mag een tweede hardcoded RHCSA-repository bevatten.

### 2.3 Verboden verwijzingen

Iedere RHCSA-repositorywaarde die niet exact overeenkomt met de centraal geconfigureerde repository is verboden. Dit geldt voor web-, raw-content-, API-, clone- en archive-URL's.

Ook indirecte fallbacklogica naar een andere of oorspronkelijke repository is verboden.

### 2.4 Installatie en herinstallatie

Een installatie of geforceerde herinstallatie moet:

1. de centrale repositoryconfiguratie gebruiken;
2. de volledige `main`-brancharchive downloaden;
3. de volledige simulatorcode uit die archive installeren;
4. alle dynamisch aanwezige hoofdstukken en vragen meenemen;
5. vóór vervanging alle syntax-, structuur- en veiligheidschecks uitvoeren;
6. bestaande voortgang en completion markers veilig behouden;
7. de oude installatie pas vervangen nadat de nieuwe versie volledig is gevalideerd;
8. bij fouten de bestaande werkende installatie intact laten;
9. tijdelijke bestanden veilig opruimen.

De installer mag hoofdstukken niet afzonderlijk downloaden via een hardcoded lijst of vaste numerieke hoofdstuklus.

### 2.5 Updates

CLI, Web UI en onderhoudsscripts moeten voor updates exact dezelfde centrale bronconfiguratie gebruiken. Er mag geen afwijkende updatebron bestaan.

### 2.6 Releasecheck

De release moet falen zodra buiten het centrale configuratiebestand een hardcoded RHCSA GitHub-repository wordt gevonden.

---

## 3. Dynamische hoofdstukdetectie

### 3.1 Bron van waarheid

Het aantal hoofdstukken mag nergens hardcoded zijn. Hoofdstukken moeten dynamisch worden ontdekt onder:

```text
RHCSA_EX200_Exam_Simulator/questions/<nummer>/
```

Een hoofdstuk is actief wanneer:

- de mapnaam volledig numeriek is;
- de map minimaal één geldig `lab_*.sh`-bestand bevat.

### 3.2 Ondersteunde aantallen

De simulator moet zonder codewijziging functioneren met bijvoorbeeld:

```text
10 hoofdstukken
12 hoofdstukken
15 hoofdstukken
20 hoofdstukken
```

### 3.3 Hoofdstuktitels

Hoofdstuktitels worden gelezen uit één metadatafile, bijvoorbeeld:

```text
objective_titles.json
```

Wanneer voor een hoofdstuk geen titel aanwezig is, wordt als fallback gebruikt:

```text
Chapter <nummer>
```

### 3.4 CLI en Web UI

CLI en Web UI moeten dezelfde dynamische hoofdstukbron gebruiken. Nieuwe hoofdstukken moeten na een update, upload of herinstallatie automatisch zichtbaar worden.

### 3.5 Geen placeholders

Lege hoofdstukken worden niet getoond. Meldingen, navigatie-items en placeholderpagina's voor hoofdstukken zonder geldige vragen moeten worden verwijderd.

---

## 4. Uniforme vraagstructuur

Alle actieve vragen moeten dezelfde structuur volgen en bestaan uit één zelfstandig shellscript:

```text
questions/<hoofdstuk>/lab_<nummer>_<naam>.sh
```

De oude actieve structuur met afzonderlijke bestanden is niet toegestaan:

```text
questions/<hoofdstuk>/q001/
├── metadata.yaml
├── setup.sh
├── validate.sh
└── cleanup.sh
```

Iedere actieve lab moet minimaal bevatten:

```bash
IS_LAB=true
LAB_ID="..."
QUESTION="..."
LAB_TASK_COUNT=<n>

TASK_1_QUESTION="..."
TASK_1_HINT="..."
TASK_1_COMMAND_1="..."

HINT=$(_build_hint)

prepare_lab() { ...; }
check_tasks() { ...; }
cleanup_lab() { ...; }
```

Aanvullende verplichte of aanbevolen metadata, zoals moeilijkheidsniveau, objective en categorie, moet op één uniforme manier worden vastgelegd.

Iedere lab moet:

- slagen met `bash -n`;
- veilig kunnen worden gesourced;
- alle verplichte variabelen bevatten;
- de functies `prepare_lab`, `check_tasks` en `cleanup_lab` bevatten;
- een unieke, stabiele en beschrijvende `LAB_ID` hebben.

---

## 5. LAB_ID-eisen

Iedere lab moet een unieke en stabiele `LAB_ID` hebben.

Niet toegestaan wanneer de waarde vaker voorkomt:

```bash
LAB_ID="lab_01"
```

Aanbevolen voorbeelden:

```bash
LAB_ID="dnf_install_remove_single"
LAB_ID="selinux_persistent_web_context"
LAB_ID="storage_lvm_extend_filesystem"
```

De `LAB_ID` is de primaire sleutel voor:

- voortgang;
- completion markers;
- migratie na bestandsverplaatsingen;
- koppeling tussen CLI en Web UI;
- detectie van dubbele vragen.

Een upload, update of release moet dubbele `LAB_ID`s weigeren.

---

## 6. Onafhankelijke taken

Iedere taak binnen een lab moet volledig zelfstandig uitvoerbaar en controleerbaar zijn.

Niet toegestaan:

- één taak maakt meerdere taken groen;
- meerdere taken valideren uitsluitend dezelfde globale systeemtoestand;
- taak 2 is alleen uitvoerbaar nadat taak 1 is uitgevoerd, tenzij dit expliciet als state-reversalscenario is ontworpen;
- taak 1 wordt groen doordat taak 2 is uitgevoerd;
- taak 1 wordt rood doordat taak 3 een eerdere toestand ongedaan maakt;
- een oude marker maakt een gewijzigde taak automatisch groen;
- sequentiële afhankelijkheid zonder expliciete marker- of poginglogica.

Voorbeeld van fout ontwerp:

```bash
rpm -q tree && TASK_STATUS[0]="true"
! rpm -q tree && TASK_STATUS[2]="true"
```

Wanneer een latere taak `tree` verwijdert, mag een eerder correct uitgevoerde installatietaak niet opnieuw rood worden.

Iedere taak krijgt waar mogelijk:

- een eigen outputbestand;
- een eigen artifact;
- een eigen live check;
- een eigen statusberekening;
- een eigen completion marker wanneer state reversal van toepassing is.

---

## 7. Hidden completion markers

### 7.1 Toepassing

Hidden markers worden gebruikt voor taken waarvan een latere taak de eerder bereikte toestand bewust ongedaan maakt, waaronder:

```text
installeren -> verwijderen
user aanmaken -> user verwijderen
service enable -> service disable
repo enable -> repo disable
firewallregel toevoegen -> firewallregel verwijderen
bestand aanmaken -> bestand verwijderen
```

Voor volledig onafhankelijke outputtaken zonder state reversal worden geen markers gebruikt, tenzij daar een aantoonbare functionele reden voor bestaat.

### 7.2 Standaardlocatie

```text
/tmp/exam/.completed/<LAB_ID>/task_<N>
```

Voorbeeld:

```text
/tmp/exam/.completed/dnf_install_remove_single/task_1
```

### 7.3 Basisfuncties

Een uniforme implementatie moet functies bieden zoals:

```bash
_marker_dir() {
  echo "/tmp/exam/.completed/$LAB_ID"
}

_mark_done() {
  mkdir -p "$(_marker_dir)"
  touch "$(_marker_dir)/task_$1"
}

_is_done() {
  [[ -f "$(_marker_dir)/task_$1" ]]
}
```

### 7.4 Validatieregels

Bij iedere uitvoering van `check_tasks()` geldt:

1. alle `TASK_STATUS[]`-waarden worden eerst op `false` gezet;
2. per taak wordt gecontroleerd of een geldige marker bestaat;
3. indien geen geldige marker bestaat, wordt de actuele taakcheck uitgevoerd;
4. bij succes wordt de marker aangemaakt;
5. latere taken mogen bestaande geldige markers nooit verwijderen;
6. `cleanup_lab()` mag oefenbestanden verwijderen, maar completion markers alleen bij een expliciete volledige reset;
7. markers mogen nooit de live check van een andere taak vervangen.

### 7.5 Versie- en pogingbewustheid

Markers moeten versie- of pogingbewust zijn, zodat:

- een marker van een inhoudelijk gewijzigde lab niet stilzwijgend wordt hergebruikt;
- een nieuwe poging desgewenst schoon kan starten;
- een expliciete reset alleen de bedoelde lab of poging raakt;
- gewijzigde taakdefinities opnieuw worden gevalideerd.

Dit kan bijvoorbeeld worden opgelost met een labversie, inhoudshash of poging-ID.

---

## 8. State-reversal-taken

Voor taken die elkaar logisch omkeren, moet altijd expliciete markerlogica of aantoonbare actievalidatie worden toegepast.

Voorbeeld:

```text
Taak 1: installeer tree
Taak 2: toon package-informatie
Taak 3: verwijder tree
```

Vereisten:

- na succesvolle taak 1 blijft taak 1 groen nadat taak 3 is uitgevoerd;
- taak 3 wordt niet automatisch groen wanneer het package al vóór de oefening afwezig was;
- taak 3 wordt alleen groen wanneer taak 1 eerder geldig was gemarkeerd, of wanneer taak 3 via een eigen artifact of uitvoerbestand aantoonbaar zelf de relevante actie heeft uitgevoerd;
- iedere taak heeft een eigen marker of eigen onafhankelijke validatie;
- informatie-opdrachten gebruiken een eigen outputbestand.

---

## 9. Gebruik van uitvoerbestanden

Informatie-opdrachten moeten waar mogelijk ieder een eigen uitvoerbestand gebruiken.

Voorbeelden:

```text
/tmp/exam/dnf-clean-all.txt
/tmp/exam/dnf-makecache.txt
/tmp/exam/dnf-enabled-repos.txt
/tmp/exam/dnf-check-update.txt
/tmp/exam/dnf-repos-verbose.txt
```

De kandidaat mag niet worden verplicht returncodes handmatig weg te schrijven.

Niet toegestaan:

```bash
echo $? > /tmp/exam/task.rc
```

Wel toegestaan:

```bash
dnf repolist -v > /tmp/exam/dnf-repos-verbose.txt 2>&1
```

De validator controleert dan minimaal:

- het bestand bestaat;
- het bestand is een regulier bestand en geen ongewenste symlink;
- het bestand is niet leeg;
- de inhoud past inhoudelijk bij de opdracht;
- het bestand behoort bij de juiste taak en poging.

---

## 10. Validatiemethoden

De simulator moet drie hoofdtypen validatie ondersteunen.

### 10.1 State validation

Voor blijvende configuratietoestanden, bijvoorbeeld:

```bash
rpm -q tree
systemctl is-enabled httpd
firewall-cmd --permanent --list-services
semanage fcontext -l
findmnt /data
```

Gebruik dit onder meer voor:

- users en groups;
- LVM en filesystems;
- mounts en `/etc/fstab`;
- SELinux;
- firewalld;
- systemd-services;
- networking.

### 10.2 Output validation

Voor informatie-opdrachten met een uniek outputbestand, bijvoorbeeld:

```bash
dnf repolist -v > /tmp/exam/dnf-repos.txt
rpm -qi tree > /tmp/exam/tree-info.txt
lsblk > /tmp/exam/lsblk.txt
```

### 10.3 Artifact validation

Voor opdrachten waarbij een bestand, script of configuratie moet worden gemaakt of gewijzigd, bijvoorbeeld:

```text
/etc/fstab
/usr/local/bin/script.sh
/tmp/exam/report.txt
/etc/yum.repos.d/custom.repo
```

### 10.4 Inhoudelijke validatie

Validatie mag niet alleen controleren op het bestaan van een bestand of een globale toestand. Waar relevant moet ook worden gecontroleerd op:

- juiste inhoud;
- juiste eigenaar en groep;
- juiste permissies;
- juiste SELinux-context;
- persistentie na reboot;
- semantisch juiste configuratie;
- afwezigheid van ongewenste extra configuratie.

---

## 11. Geen kunstmatige examenopdrachten

De kandidaat mag niet worden gevraagd om handelingen uit te voeren die niet passen bij een RHCSA-praktijkexamen, tenzij het expliciet om een rapportage- of verificatieopdracht gaat.

Niet wenselijk:

```bash
echo $? > /tmp/exam/task.rc
```

Wel wenselijk:

```bash
dnf info tree > /tmp/exam/tree-info.txt
```

Opdrachten moeten primair gericht zijn op configureren, beheren, verifiëren, diagnosticeren en herstellen.

---

## 12. Hints en commands

Iedere taak moet een werkende en zichtbare hint bevatten.

De parser van de Web UI moet minimaal ondersteunen:

- single-quoted waarden;
- double-quoted waarden;
- meerregelige hints;
- meerregelige commands;
- escaped shellvariabelen;
- lege optionele commandvelden;
- speciale tekens zonder beschadiging van de inhoud.

CLI en Web UI moeten exact dezelfde hintinhoud tonen en dezelfde brondata gebruiken.

Hints mogen de volledige oplossing niet onnodig prijsgeven, maar moeten voldoende richting geven om de kandidaat verder te helpen.

---

## 13. Voortgang en persistentie

### 13.1 Eén bron van waarheid

CLI en Web UI moeten dezelfde persistente voortgangsbron gebruiken of aantoonbaar betrouwbaar synchroniseren.

Minimaal op te slaan gegevens:

```json
{
  "lab_id": "dnf_install_remove_single",
  "task": 1,
  "status": "completed",
  "timestamp": "...",
  "lab_version": "...",
  "attempt_id": "..."
}
```

Hidden markers mogen onderdeel zijn van deze bron van waarheid, mits CLI en Web UI dezelfde interpretatie gebruiken.

### 13.2 Primaire sleutel

Voortgang wordt primair gekoppeld aan een unieke en stabiele `LAB_ID`, niet uitsluitend aan bestandsnaam, pad of hoofdstuknummer.

### 13.3 Upload en update

Na het toevoegen, vervangen, verplaatsen of downloaden van vragen moet bestaande voortgang direct zichtbaar blijven zonder eerst opnieuw een taak uit te voeren.

Nieuwe vragen krijgen standaard de status:

```text
not_started
```

Bestaande geldige markers en progressrecords blijven leidend.

### 13.4 Migratie van oude sleutels

De simulator moet oudere sleutelvormen kunnen herkennen en migreren, waaronder:

```text
filename
objective/filename
chapter/filename
```

Migratie moet uiteindelijk koppelen op `LAB_ID` en mag geen dubbele of verloren voortgang veroorzaken.

---

## 14. Web UI-eisen

De Web UI moet:

1. voortgang laden vóór het renderen van questions;
2. voortgang opnieuw reconciliëren nadat questions zijn gerenderd;
3. progress-endpoints zonder ongewenste browser- of proxycache aanbieden;
4. per hoofdstuk de juiste voortgang tonen;
5. per lab en per taak de juiste status tonen;
6. nieuwe uploads en repository-updates direct verwerken;
7. bestaande voortgang behouden;
8. hidden markers correct respecteren;
9. niet afhankelijk zijn van een nieuwe check-run om voortgang zichtbaar te maken;
10. duidelijke foutmeldingen tonen bij ontbrekende, ongeldige of syntactisch kapotte labs;
11. veilige path-validatie toepassen;
12. dezelfde hints, vragen en validatie-uitkomsten tonen als de CLI;
13. hoofdstukken dynamisch detecteren;
14. geen lege hoofdstukken of placeholders tonen.

Alle labpaden vanuit de Web UI moeten worden gevalideerd tegen path traversal.

Niet toestaan:

```text
../../etc/passwd
```

Padvalidatie moet minimaal canonicalisatie, allowlisting binnen de questions-tree en symlinkcontrole omvatten.

---

## 15. CLI-eisen

De CLI moet:

- dezelfde dynamische hoofdstukdetectie gebruiken als de Web UI;
- dezelfde labstructuur gebruiken;
- dezelfde markerlogica gebruiken;
- dezelfde persistente voortgangsbron gebruiken;
- voortgang tonen zonder afhankelijkheid van de Web UI;
- geen afwijkende statusberekening gebruiken;
- dezelfde `LAB_ID` als primaire sleutel gebruiken;
- dezelfde hints en taakteksten tonen;
- foutieve labs duidelijk rapporteren en veilig overslaan;
- updates uit dezelfde centrale repositoryconfiguratie uitvoeren.

---

## 16. Uploads, synchronisatie en vraagcatalogus

Bij nieuwe vragen of een repository-update moet de simulator:

1. alle dynamisch aanwezige hoofdstukken detecteren;
2. nieuwe vragen detecteren;
3. bestaande voortgang behouden;
4. oude voortgang opnieuw koppelen aan bestaande `LAB_ID`s;
5. dubbele `LAB_ID`s weigeren;
6. ontbrekende, foutieve of onveilige labs rapporteren;
7. de vraagcatalogus en hoofdstuktitels automatisch regenereren of valideren;
8. Web UI en CLI zonder handmatige cache-reset synchroniseren;
9. verwijderde vragen gecontroleerd als verwijderd of gearchiveerd behandelen;
10. de vorige werkende catalogus behouden wanneer validatie mislukt.

Een upload of update mag nooit leiden tot:

- lege voortgang;
- verdwenen hoofdstukvoortgang;
- dubbele vragen;
- een kapotte Web UI;
- genegeerde geldige markerbestanden;
- gedeeltelijk geïnstalleerde vragen;
- een inconsistentie tussen CLI en Web UI.

---

## 17. Speciale aandacht voor softwaremanagement en hoofdstuk 2

Softwaremanagementlabs bevatten relatief veel state-reversalrisico's.

Voorbeelden waarvoor markerlogica of aantoonbare actievalidatie vereist is:

```text
install -> info -> remove
enable repo -> inspect -> disable repo
flatpak install -> list -> remove
package group install -> query -> remove
```

Voor deze labs geldt:

- een installatietaak blijft groen nadat een verwijdertaak is uitgevoerd;
- een verwijdertaak wordt niet automatisch groen wanneer het package al afwezig was;
- iedere informatie-opdracht gebruikt een eigen uitvoerbestand;
- iedere state-reversaltaak heeft een eigen geldige marker;
- globale package-status mag niet meerdere taken tegelijk groen maken;
- een gewijzigde labversie mag oude markers niet blind hergebruiken.

---

## 18. DNF-labs

DNF-labs moeten worden ontworpen als unieke en onafhankelijke opdrachten.

Voorbeeld van een goede taakverdeling:

```text
Taak 1: dnf clean all > /tmp/exam/dnf-clean-all.txt
Taak 2: dnf makecache > /tmp/exam/dnf-makecache.txt
Taak 3: dnf repolist enabled > /tmp/exam/dnf-enabled-repos.txt
Taak 4: dnf check-update > /tmp/exam/dnf-check-update.txt
Taak 5: dnf repolist -v > /tmp/exam/dnf-repos-verbose.txt
```

Validatie mag niet uitsluitend steunen op gedeelde globale cachetoestand zoals:

```text
/var/cache/dnf
/var/cache/yum
```

Iedere taak moet een eigen controleerbaar resultaat of artifact hebben.

---

## 19. Inhoudelijke RHCSA-dekking

De simulator moet aantoonbaar alle actuele RHCSA v10-objectives afdekken.

Per objective moet een dekkingsmatrix worden bijgehouden:

| Objective | Labs | Basis | Gemiddeld | Complex | Troubleshooting | Dekking |
|---|---:|---:|---:|---:|---:|---:|

Iedere objective moet meerdere invalshoeken bevatten:

- basisuitvoering;
- configuratie;
- verificatie;
- persistentie na reboot;
- foutdiagnose;
- herstel;
- exam traps;
- gecombineerde scenario's.

Per regulier hoofdstuk worden als streefwaarde minimaal 40 tot 50 labs opgenomen, met aantoonbare spreiding in complexiteit en zonder kunstmatige duplicatie.

Bonushoofdstukken behandelen relevante RHCSA v9-objectives die in v10 niet of minder prominent voorkomen.

---

## 20. Moeilijkheidsbandbreedte

Iedere vraag krijgt een moeilijkheidsniveau, bijvoorbeeld 1 tot en met 5.

Per hoofdstuk moet een evenwichtige verdeling bestaan tussen:

- niveau 1: enkelvoudige basisactie;
- niveau 2: basisactie met verificatie;
- niveau 3: meerdere samenhangende stappen;
- niveau 4: troubleshooting of state recovery;
- niveau 5: gecombineerd examenscenario met meerdere objectives.

Het niveau moet in de labmetadata beschikbaar zijn voor CLI, Web UI, catalogus en dekkingsrapportage.

---

## 21. Verboden package: tmux

Geen enkele actieve vraag mag `tmux` installeren, verwijderen, wijzigen, updaten of als oefenpackage gebruiken, omdat de Web UI-terminal hiervan afhankelijk is.

Een releasecheck moet falen bij iedere ongeoorloofde `tmux`-referentie in actieve vragen.

Documentatie of comments waarin uitsluitend wordt uitgelegd dat `tmux` verboden is, moeten door de check onderscheidbaar zijn van daadwerkelijke oefenopdrachten.

---

## 22. Beveiliging en robuustheid

De simulator moet beschermen tegen:

- path traversal;
- shell injection via bestandsnamen, metadata of parameters;
- ongevalideerde labpaden;
- onveilige tijdelijke bestanden;
- symlinkaanvallen;
- race conditions bij tijdelijke bestanden;
- ongecontroleerde `rm -rf`-paden;
- verwijderen buiten expliciet toegestane directories;
- installatie vanuit een onverwachte repository;
- gedeeltelijke installatie na download- of validatiefouten;
- manipulatie van voortgang of markers via onveilige paden;
- het sourcen van onbetrouwbare of niet-gevalideerde labs.

Veilige implementaties moeten onder meer gebruikmaken van:

- canonical path-controle;
- allowlists;
- `mktemp` voor tijdelijke bestanden en directories;
- veilige quoting;
- gecontroleerde permissies;
- atomaire vervanging van installaties en voortgangsbestanden;
- rollback bij mislukte updates.

---

## 23. Branding

De simulator mag een interne “Sopra Steria inspired” huisstijl bevatten, maar zonder officiële merkassets tenzij daarvoor expliciete toestemming bestaat.

Branding moet:

- optioneel zijn;
- technisch losstaan van vragen, CLI, voortgang en validatie;
- de werking niet beïnvloeden;
- bij uitschakeling geen functionele onderdelen verwijderen;
- geen officiële merkindruk wekken zonder toestemming.

---

## 24. Releasevalidatie en kwaliteitscontrole

Voor iedere release moeten minimaal de volgende controles slagen:

```bash
bash -n questions/**/*.sh
python -m py_compile webui/*.py
```

Daarnaast moet de releasepipeline controleren op:

- Bash-syntax van alle shellscripts;
- Python-syntax van alle Pythonbestanden;
- JavaScript-syntax;
- veilig kunnen sourcen van alle labs;
- aanwezigheid van alle verplichte labvelden;
- aanwezigheid van `prepare_lab`, `check_tasks` en `cleanup_lab`;
- unieke `LAB_ID`s;
- geldige en stabiele `LAB_ID`-waarden;
- geen oude actieve `q001/metadata`-mappenstructuur;
- geen Apple `._*`-bestanden;
- geen `__MACOSX`-directories;
- geen dubbele vraagbestanden;
- geen sequentiële taakafhankelijkheden zonder markerlogica;
- geen ongeoorloofde `tmux`-referenties in actieve vragen;
- geen oorspronkelijke repositoryverwijzingen;
- exact één centrale repositoryconfiguratie;
- dynamische hoofdstukdetectie;
- geen hardcoded hoofdstuklussen of limieten;
- geen lege hoofdstukken;
- geen placeholders;
- vraagcatalogus consistent met de questions-tree;
- geldige hoofdstuktitelmetadata;
- veilige labpaden;
- geen ongecontroleerde destructieve commando's;
- juiste markersemantiek bij state reversal;
- eigen outputbestanden voor informatie-opdrachten;
- afwezigheid van kunstmatige returncode-opdrachten.

De release moet falen wanneer één blockercheck niet slaagt.

---

## 25. Wijzigingsbeleid

Verbeteringen buiten deze requirements worden niet automatisch doorgevoerd.

Werkwijze:

1. verbetering signaleren;
2. probleem en risico documenteren;
3. voorgestelde oplossing beschrijven;
4. impact en backward compatibility beschrijven;
5. eerst ter goedkeuring voorleggen;
6. pas na expliciete goedkeuring implementeren.

Kritieke fouten die installatie, dataveiligheid of beveiliging direct raken mogen als blocker worden gemeld, maar niet stilzwijgend inhoudelijk worden gewijzigd buiten de afgesproken scope.

---

## 26. Acceptatiecriteria

De oplevering wordt pas geaccepteerd wanneer minimaal aan alle onderstaande criteria is voldaan.

### 26.1 Repository en installatie

1. Een schone VM-installatie downloadt uitsluitend data uit `ytra-redhat/RHCSA.github.io`.
2. De gebruikte branch is `main`.
3. Een volledige codescan vindt nul RHCSA-repositoryverwijzingen buiten de centraal geconfigureerde repository.
4. De installer bevat geen hardcoded hoofdstuklimiet.
5. De installer installeert automatisch alle geldige hoofdstukken onder `questions/`.
6. De oude installatie wordt pas vervangen na volledige validatie van de nieuwe installatie.
7. Een mislukte update laat de bestaande werkende installatie intact.

### 26.2 Hoofdstukken en vragen

8. CLI en Web UI tonen hetzelfde dynamisch vastgestelde hoofdstukaantal.
9. Hoofdstuk 11 en 12 worden automatisch zichtbaar wanneer zij aanwezig zijn.
10. Een later toegevoegd hoofdstuk 13 wordt zonder codewijziging zichtbaar.
11. Alle actieve vragen gebruiken uitsluitend de uniforme `lab_*.sh`-structuur.
12. Alle labs zijn syntactisch correct en veilig sourcebaar.
13. Alle `LAB_ID`s zijn uniek.
14. Lege hoofdstukken en placeholders worden niet getoond.

### 26.3 Voortgang en synchronisatie

15. Progress in CLI en Web UI is gelijk.
16. Uploads, updates en herinstallaties behouden bestaande voortgang.
17. Web UI-progress blijft direct zichtbaar na een upload of update.
18. Nieuwe vragen krijgen standaard `not_started`.
19. Verplaatste vragen behouden voortgang via `LAB_ID`.
20. Oude sleutelvormen worden gecontroleerd gemigreerd.

### 26.4 Taken en validatie

21. State-reversallabs gebruiken geldige, versie- of pogingbewuste markerlogica.
22. Informatie-opdrachten gebruiken eigen outputbestanden.
23. Handmatig wegschrijven van returncodes is niet vereist.
24. Onafhankelijke taken beïnvloeden elkaars status niet.
25. Een verwijdertaak wordt niet groen alleen omdat het doel al vóór de oefening afwezig was.
26. Iedere taak toont een werkende hint in zowel CLI als Web UI.
27. Geen actieve vraag gebruikt `tmux` als oefenpackage.

### 26.5 Specifieke state-reversaltest

De relevante install/info/remove-lab, waaronder de bestaande `lab_12` zolang die naam in gebruik is, moet correct functioneren bij:

1. eerst taak 1, daarna taak 3;
2. eerst taak 3 zonder taak 1;
3. taak 1, daarna taak 2, daarna taak 3;
4. Web UI-refresh na taak 3;
5. CLI-check na taak 3;
6. herstart van de Web UI;
7. upload of update van andere vragen zonder verlies van de bestaande status;
8. inhoudelijke wijziging van de lab waarbij een oude marker niet ten onrechte geldig blijft.

### 26.6 Releasechecks

Alle releasechecks uit hoofdstuk 24 moeten volledig slagen.

---

## 27. Gewenste eindtoestand

De questions-tree bestaat uiteindelijk uit dynamisch ontdekte numerieke hoofdstukken:

```text
questions/
├── 1/
├── 2/
├── 3/
├── ...
├── 10/
├── 11/
├── 12/
└── <later toegevoegde hoofdstukken>/
```

Actieve hoofdstukken bevatten uitsluitend:

```text
lab_*.sh
```

De simulator moet robuust genoeg zijn om willekeurig vragen en hoofdstukken toe te voegen, te vervangen, te verplaatsen of te verwijderen zonder dat bestaande voortgang, validatie, installatie, CLI-status of Web UI-status kapotgaat.
