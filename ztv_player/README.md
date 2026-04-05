# zTv Player

`zTv Player` je Flutter IPTV/Xtream Codes player sa podrskom za:

- vise playlist-a
- Live TV kategorije i kanale
- Movies i Series kataloge
- EPG ucitavanje i archive playback
- lokalno cuvanje aktivne playlist-e preko Hive storage-a

## Trenutno stanje

Projekat je funkcionalan, ali je u toku cleanup i refaktorisanje codebase-a. Fokus trenutnog rada je:

- smanjenje duplikacije u UI sloju
- uklanjanje mrtvih ili nedovrsenih dijelova arhitekture
- poboljsanje sigurnosti i preglednosti settings toka
- uvodjenje stvarnih testova umjesto template testova

## Tehnologije

- `Flutter`
- `Dio` za HTTP komunikaciju
- `Hive` i `hive_flutter` za lokalni storage
- `json_serializable` i `json_annotation` za modele
- `better_player_plus` za video playback
- `cached_network_image` za remote slike/postere

## Struktura projekta

- `lib/main.dart`
  Startup, Hive bootstrap i root navigation.
- `lib/models`
  Domenski modeli za playlist-e, Live TV, VOD, series i EPG.
- `lib/services`
  API, playback, favorites, settings i content servisni sloj.
- `lib/storage`
  Repository logika za playlist persistence i aktivni snapshot.
- `lib/screens`
  Glavni UI flow za playlist setup, browsing i playback.
- `lib/widgets`
  Reusable UI komponente i shared content listing sloj.
- `test`
  Unit i widget testovi.

## Glavni tok aplikacije

1. Aplikacija inicijalizuje Hive i otvara lokalne boxeve.
2. Aktivna playlist-a se ucitava iz storage-a.
3. Snapshot aktivne playlist-e se hidrira u lokalne content boxeve.
4. Screenovi citaju te boxeve i renderuju Live TV, Movies i Series sekcije.
5. Detalji i playback koriste aktivnu playlist-u za pozive prema Xtream API-ju.

## Pokretanje projekta

1. Instaliraj Flutter SDK.
2. Pokreni `flutter pub get`.
3. Pokreni aplikaciju sa `flutter run`.

## Korisne komande

- `flutter pub get`
- `flutter run`
- `flutter test`
- `flutter analyze`
- `dart run build_runner build --delete-conflicting-outputs`

## Napomene za razvoj

- Aktivna playlist-a se trenutno cuva lokalno.
- Neki serveri vracaju nekonzistentan JSON, pa `XtreamApiService` ima dodatnu sanitizaciju response-a.
- Projekat trenutno nema zavrsen CI signal u ovom okruzenju jer su `flutter analyze` i `flutter test` spori i timeout-uju u terminal sesiji.

## Prioriteti za naredni rad

- dodatni testovi za services i repository sloj
- sigurnije cuvanje osjetljivih podataka
- uklanjanje preostalih dupliranih flow-ova u player/detail screenovima
- zamjena krhkih package internal import zavisnosti stabilnijim API-jem
