# 🚗 Saobraćajke - Serbian Traffic Accidents Dashboard

A Flutter application for visualizing and analyzing traffic accident data from Serbian Open Data sources. The app provides interactive dashboards, charts, and a map view to explore traffic incidents across Serbia.

## 📱 Features

### Dashboard (Home Screen)

- **Key Metrics Overview**: Total accidents, fatalities, injuries, and material damage counts
- **Year-over-Year Comparison**: Track changes from the previous year
- **Filter by Year & Police Department**: Drill down into specific regions and time periods

### Interactive Charts

- **Monthly Trends**: Line charts showing accident patterns throughout the year
- **Accident Type Breakdown**: Distribution by severity (fatal, injury, material damage)
- **Top Locations**: Bar charts of most affected cities/stations
- **Time Analysis**: Accidents by season, time of day, and weekend vs. weekday

### Map View

- **Clustered Markers**: Efficiently displays thousands of accident locations
- **Color-Coded Severity**:
  - 🔴 Red: Fatal accidents
  - 🟠 Orange: Accidents with injuries
  - 🟢 Green: Material damage only
- **Detailed Accident Info**: Tap markers to view full incident details
- **Filtering**: Filter map data by year and police department

## 🏗️ Architecture

The app follows a clean architecture pattern:

```
lib/
├── core/
│   └── services/          # Database service, utilities
├── data/
│   └── repositories/      # Data access layer (SQLite queries)
├── domain/
│   └── models/            # Data models (AccidentModel, etc.)
├── presentation/
│   ├── logic/             # State management (Riverpod providers)
│   └── ui/
│       ├── screens/       # Home, Map screens
│       └── widgets/       # Reusable UI components, charts
└── main.dart
```

## 🛠️ Tech Stack

- **Flutter** 3.10+ (Dart)
- **State Management**: [flutter_riverpod](https://riverpod.dev/) ^3.2.0
- **Database**: [sqflite](https://pub.dev/packages/sqflite) ^2.4.2 (SQLite)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart) ^1.1.1
- **Maps**: [flutter_map](https://pub.dev/packages/flutter_map) ^8.2.2 + OpenStreetMap tiles
- **Map Clustering**: [flutter_map_marker_cluster](https://pub.dev/packages/flutter_map_marker_cluster) ^8.2.2
- **Localization**: [intl](https://pub.dev/packages/intl) ^0.20.2

## 📦 Data Source

The app uses a pre-packaged SQLite database (`assets/db/serbian_traffic.db.zip`) containing traffic accident records from Serbian open data sources. The database is extracted on first launch.

**Database Schema:**

- `accidents` - Individual accident records with date, location (lat/lng), type, participants
- `departments` - Police departments/regions
- `types` - Accident severity types
- `stations` - Police stations

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.10.7
- Visual Studio Code

### Installation

```bash
# Clone the repository
git clone https://github.com/your-username/saobracajke.git
cd saobracajke

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Traffic accident data provided by [Serbian Open Data Portal](https://data.gov.rs/)
- Map tiles by [OpenStreetMap](https://www.openstreetmap.org/)

## 📧 Contact

For questions or feedback, please open an issue on GitHub.

---

Made with ❤️ in Serbia 🇷🇸
