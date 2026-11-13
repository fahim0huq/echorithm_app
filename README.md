# Echorithm

A personalised news app built with Flutter and [NewsAPI](https://newsapi.org).
Pick the topics you care about, and Echorithm shows top headlines only for those.

## Features

- Top headlines by category (General, Business, Technology, Sports, Health, Science, Entertainment)
- **My Interests**: choose your topics; the choice is saved on the device
- Featured story card and a clean news list
- Infinite scroll (pagination, 20 articles per page)
- Pull to refresh
- Article page with a collapsing header image and a "Read full article" button

## Tech

Flutter (Material 3), `http`, `google_fonts`, `url_launcher`, `shared_preferences`.
State is kept simple: `StatefulWidget` + `FutureBuilder`.

## Project structure

```
lib/
  main.dart                     app entry, loads saved interests
  app.dart                      MaterialApp + theme
  Data/
    urls.dart                   API settings
    categories.dart             list of categories
    models/article_model.dart   Article + fromJson
    service/news_service.dart   NewsAPI call (with pagination)
    service/preferences_service.dart  saves the user's interests
  ui/
    screens/                    home, detail, interests
    widgets/                    cards, chips, loading and error views
    utils/app_theme.dart        colours and theme
```

## Run it

1. Get a free API key at https://newsapi.org.
2. Copy `lib/Data/api_key.example.dart` to `lib/Data/api_key.dart` and put your key in it.
   (`api_key.dart` is git-ignored, so your key is never uploaded.)
3. Run:

```bash
flutter pub get
flutter run
```

The free NewsAPI plan only works from a phone or emulator, not from a web browser.
