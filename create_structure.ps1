New-Item -ItemType Directory -Path "lib"
New-Item -ItemType File -Path "lib/main.dart"

foreach ($folder in @("screens", "models", "data", "widgets")) {
    New-Item -ItemType Directory -Path "lib/$folder"
}

New-Item -ItemType File -Path "lib/screens/home_screen.dart"
New-Item -ItemType File -Path "lib/screens/quiz_screen.dart"
New-Item -ItemType File -Path "lib/screens/edukacja_screen.dart"
New-Item -ItemType File -Path "lib/screens/wynik_screen.dart"

New-Item -ItemType File -Path "lib/models/question.dart"
New-Item -ItemType File -Path "lib/models/wynik.dart"

New-Item -ItemType File -Path "lib/data/questions.dart"

New-Item -ItemType File -Path "lib/widgets/question_card.dart"
New-Item -ItemType File -Path "lib/widgets/wynik_widget.dart"
