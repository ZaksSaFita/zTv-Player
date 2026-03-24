# Movies & Series Guide

Ovaj vodič ti pokazuje kako da za `Movies` i `Series` napraviš isti flow koji sada već imaš za `Live`:

- category screen
- items screen
- detail/player screen
- content ispod playera
- odvojeni `sort`, `view` i `search` state

Ne pravi sve iz nule. Uzmi postojeće `Live` fajlove kao šablon i samo prilagodi podatke.

---

## 1. Šta već imaš i trebaš kopirati

Ovo su glavni fajlovi koje koristiš kao osnovu:

- `lib/screens/livetv_screen.dart`
  - category list screen
- `lib/screens/live_category_screen.dart`
  - items screen unutar kategorije
- `lib/screens/live_channel_player_screen.dart`
  - detail screen sa playerom i custom content ispod
- `lib/widgets/media_detail_scaffold.dart`
  - zajednički layout: `AppBar + player + custom content`
- `lib/widgets/app_video_player.dart`
  - zajednički player widget
- `lib/services/live_service.dart`
  - category read flow
- `lib/services/live_channel_service.dart`
  - items read flow
- `lib/services/playback_service.dart`
  - sklapanje playable URL-a

Za `Movies` i `Series` trebaš pratiti isti obrazac.

---

## 2. Movies flow

Za filmove ti trebaju 3 nivoa:

1. movie categories
2. movies unutar kategorije
3. movie detail/player screen

### 2.1 Napravi movie items screen

Napravi novi screen, npr:

- `lib/screens/movie_category_screen.dart`

Najlakše:
- kopiraj `lib/screens/live_category_screen.dart`
- zamijeni `LiveCategory` sa `VodCategory`
- zamijeni `LiveChannel` sa `VodMovie`
- zamijeni `LiveChannelPlayerScreen` sa budućim `MoviePlayerScreen`

Šta treba promijeniti:

- imports
- service koji čita podatke
- title/subtitle na karticama
- `onTap` da vodi na movie detail screen

### 2.2 Napravi movie service za items

Napravi novi service, npr:

- `lib/services/movie_item_service.dart`

Možeš bukvalno pratiti obrazac iz:

- `lib/services/live_channel_service.dart`

Treba ti:

- `listenable()` za Hive box `vod_movies`
- `getMoviesByCategory(String categoryId)`
- `getVisibleMovies({required String categoryId, required SortType sortType, required String query})`

Unutra koristi:

- `AppSort.applyNamedSort(...)`
- `AppSort.applySearchFilter(...)`

Za movie sort tipično koristi:

- `idOf: (movie) => movie.id`
- `nameOf: (movie) => movie.name`

Ako kasnije dodaš rating ili year sort, to ide kroz `customValueOf`.

### 2.3 Poveži MoviesScreen sa movie items screenom

U:

- `lib/screens/movies_screen.dart`

kad klikneš kategoriju:

- `Navigator.push(...)`
- otvori `MovieCategoryScreen(category: category)`

To radi isto kao `Live -> category -> channels`.

### 2.4 Napravi movie detail/player screen

Napravi:

- `lib/screens/movie_player_screen.dart`

Najlakše:
- kopiraj `lib/screens/live_channel_player_screen.dart`
- očisti `Live/Archive` tabove
- ostavi samo content za movie detalje

Movie detail screen treba da koristi:

- `MediaDetailScaffold`
- `AppVideoPlayer`
- `PlaybackService.resolveMovieStreamUrl(...)`

### 2.5 Šta ide ispod playera za film

U `content:` dijelu stavi ono što želiš da korisnik vidi:

- naziv filma
- opis (`plot`)
- godina (`year`)
- možda rating kad ga dodaš u model
- možda poster/cover info ako želiš dodatno

Ako ti je cilj da ostane jednostavno:

- jedna info kartica
- par redova ispod (`year`, `category`, `stream id`)

To je dovoljno za početak.

---

## 3. Series flow

Za serije ti trebaju 4 nivoa:

1. series categories
2. series unutar kategorije
3. series detail/player screen
4. sezone + epizode unutar detail screena

### 3.1 Napravi series items screen

Napravi:

- `lib/screens/series_category_screen.dart`

Najlakše:
- kopiraj `lib/screens/live_category_screen.dart`
- zamijeni modele i service

Trebaš koristiti:

- `SeriesCategory` kao category model
- `Series` kao item model

### 3.2 Napravi series item service

Napravi:

- `lib/services/series_item_service.dart`

Isti obrazac kao:

- `lib/services/live_channel_service.dart`

Treba ti:

- `listenable()` za Hive box `series`
- `getSeriesByCategory(String categoryId)`
- `getVisibleSeries({required String categoryId, required SortType sortType, required String query})`

### 3.3 Poveži SeriesScreen sa series items screenom

U:

- `lib/screens/series_screen.dart`

klik na kategoriju treba da vodi na:

- `SeriesCategoryScreen(category: category)`

### 3.4 Napravi series detail/player screen

Napravi:

- `lib/screens/series_player_screen.dart`

Za početak koristi:

- `MediaDetailScaffold`
- `AppVideoPlayer`

Ali ovdje player ne mora odmah puštati ništa kad uđeš u seriju.

Pametniji flow za serije:

- gore `AppBar`
- player
- ispod lista sezona
- klik na sezonu otvara epizode
- klik na epizodu tek tada mijenja player source

### 3.5 Sezone i epizode

Pošto si tražio:

- čista sezona lista
- klik na sezonu otvara dropdown sa epizodama

to najlakše radiš sa:

- `ExpansionTile`

Znači u content dijelu detail screena:

- `ListView`
- za svaku sezonu jedan `ExpansionTile`
- unutar njega lista epizoda

Klik na epizodu:

- postavi `selectedEpisode`
- pozovi `PlaybackService.resolveEpisodeStreamUrl(...)`
- proslijedi novi URL u `AppVideoPlayer`

To je isti princip koji sada koristiš za archive unutar `Live`.

---

## 4. Kako da organizuješ state

Za svaki screen čuvaj state odvojeno.

Već imaš to za glavne tabove i live category screen.

Za nove detail/item screenove radi isto:

- napravi poseban `ScreenUiController` u `AppSort`
- ili poseban stateless/local controller ako je screen samo jedan

Za `Movies` i `Series` item screenove preporuka:

- `movieCategoryController`
- `seriesCategoryController`

Ako kasnije budeš htio odvojeni state i za detail search:

- `movieDetailController`
- `seriesDetailController`

---

## 5. Koje postojeće dijelove reuse-aš

Nemoj duplirati ovo:

- `AppListCard`
  - `lib/widgets/content_cards.dart`
- `AppGridCard`
  - `lib/widgets/content_cards.dart`
- `EmptyState`
  - `lib/widgets/empty_state.dart`
- `AppSearchField`
  - `lib/widgets/app_search_field.dart`
- `MediaDetailScaffold`
  - `lib/widgets/media_detail_scaffold.dart`
- `AppVideoPlayer`
  - `lib/widgets/app_video_player.dart`
- `PlaybackService`
  - `lib/services/playback_service.dart`
- `AppSort.applyNamedSort(...)`
  - `lib/helpers/sort.dart`
- `AppSort.applySearchFilter(...)`
  - `lib/helpers/sort.dart`

To su tvoje globalne baze. Novi screenovi samo treba da ih koriste.

---

## 6. Minimalan redoslijed rada

Ako želiš da radiš bez haosa, idi ovim redom:

### Movies

1. napravi `movie_item_service.dart`
2. napravi `movie_category_screen.dart`
3. poveži `movies_screen.dart` da otvara taj screen
4. napravi `movie_player_screen.dart`
5. poveži klik na movie card da otvara detail

### Series

1. napravi `series_item_service.dart`
2. napravi `series_category_screen.dart`
3. poveži `series_screen.dart`
4. napravi `series_player_screen.dart`
5. dodaj `ExpansionTile` za sezone
6. poveži klik na epizodu da mijenja player source

---

## 7. Najjednostavniji copy/paste mapping

Ako želiš bukvalno najbrže:

### Za movie items screen

Kopiraj:

- `lib/screens/live_category_screen.dart`

Promijeni:

- `LiveCategory` -> `VodCategory`
- `LiveChannel` -> `VodMovie`
- `LiveChannelService` -> `MovieItemService`
- `LiveChannelPlayerScreen` -> `MoviePlayerScreen`
- `Search channels` -> `Search movies`
- ikone `Icons.tv` -> `Icons.movie`

### Za series items screen

Kopiraj:

- `lib/screens/live_category_screen.dart`

Promijeni:

- `LiveCategory` -> `SeriesCategory`
- `LiveChannel` -> `Series`
- `LiveChannelService` -> `SeriesItemService`
- `LiveChannelPlayerScreen` -> `SeriesPlayerScreen`
- `Search channels` -> `Search series`
- ikone `Icons.tv` može ostati `Icons.tv`

### Za movie detail screen

Kopiraj:

- `lib/screens/live_channel_player_screen.dart`

Obriši:

- `DefaultTabController`
- `Live/Archive` tabove
- EPG/Archive logiku

Ostavi:

- `MediaDetailScaffold`
- `AppVideoPlayer`
- jedan `ListView` sa movie detaljima

### Za series detail screen

Kopiraj:

- `lib/screens/live_channel_player_screen.dart`

Obriši:

- EPG dio
- archive dio

Stavi:

- `ListView`
- `ExpansionTile` po sezoni
- epizode unutra

---

## 8. Šta NE trebaš raditi

Nemoj:

- praviti novi globalni card model
- praviti poseban player widget za svaki tip
- duplirati sort/search helper logiku
- direktno trpati Hive query logiku u screen ako već imaš service sloj

Već imaš dobru bazu:

- `models` za podatke
- `services` za dohvat i filtriranje
- `widgets` za reusable UI
- `screens` za sastavljanje flow-a

---

## 9. Praktična preporuka

Ako krećeš odmah dalje, idi prvo na `Movies`.

Razlog:

- jednostavnije je od `Series`
- nema sezona/epizoda
- isti je obrazac kao `Live`, samo bez EPG/archive

Kad `Movies` proradi kako treba, onda kopiraš isti detail/player obrazac na `Series`, i samo dodaš `ExpansionTile` za sezone i epizode.

---

## 10. Ako želiš moj preporučeni sljedeći korak

Najčišći sljedeći posao je:

1. `movie_item_service.dart`
2. `movie_category_screen.dart`
3. `movie_player_screen.dart`

Kad to bude gotovo, `Series` ćeš uraditi mnogo brže jer ćeš samo pratiti isti obrazac plus epizode.
