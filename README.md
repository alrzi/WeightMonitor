# WeightMonitor

## Описание

WeightMonitor — приложение для iPhone и Apple Watch, которое помогает фиксировать вес, просматривать историю и динамику изменений, а также поддерживать данные на устройствах в актуальном состоянии. Интерфейс построен на **SwiftUI**; **UIKit** отвечает за жизненный цикл iOS-приложения и встраивание SwiftUI-экрана.

## Основные возможности

- Добавление, редактирование и удаление записей веса.
- История измерений с постраничной загрузкой и состояниями загрузки, пустого списка и ошибки.
- График динамики веса и переключение между метрической и имперской системами единиц.
- Локальное хранение данных на каждом устройстве.
- Двусторонняя синхронизация записей между iPhone и Apple Watch.

## Архитектура системы

Проект следует принципам **модульной Clean Architecture**: зависимости направлены к доменному слою, а конкретные реализации изолированы на границе данных. Для представления используется **MVVM**, а навигация и сборка экранов управляются отдельным Flow/Coordinator-слоем.

| Слой / модуль | Назначение |
| --- | --- |
| **App** | Composition root: собирает зависимости, запускает синхронизацию и связывает пользовательские сценарии. |
| **Features** | SwiftUI-экраны истории и ввода веса, их ViewModel и переиспользуемые UI-компоненты. |
| **Domain** | Независимые бизнес-модели, контракты репозиториев и менеджеры операций с весом и единицами измерения. |
| **Data** | Реализует контракты Domain, хранит записи и параметры пользователя локально, готовит изменения к синхронизации. |
| **Sync** | Передаёт изменения между устройствами, применяет входящие данные и контролирует состояние исходящей очереди. |
| **WatchApp** | Самостоятельный watchOS-клиент с теми же Domain/Data/Sync-модулями. |

## Потоки данных и API

```mermaid
graph TD
    User[Пользователь]

    subgraph iPhone["iPhone-приложение"]
        UIKit["UIKit: жизненный цикл и хостинг"]
        PhoneUI["SwiftUI: история, график, ввод веса"]
        Flow["Flow / Coordinator: навигация и композиция"]
        PhoneVM["MVVM: ViewModel"]
        Domain["Domain: модели, менеджеры, контракты"]
        Repository["Data: репозиторий и sync outbox"]
        PhoneDB["Локальное хранилище: SQLite / GRDB"]
        Settings["Настройки единиц: UserDefaults"]
        PhoneSync["Sync: очередь, версии, применение изменений"]
    end

    subgraph AppleAPIs["Системные API Apple"]
        Charts["Swift Charts"]
        FileSystem["Foundation / Documents"]
        WC["WatchConnectivity / WCSession"]
    end

    subgraph Watch["Apple Watch"]
        WatchUI["SwiftUI: ввод и история"]
        WatchVM["MVVM + Domain/Data"]
        WatchDB["Локальное SQLite-хранилище"]
    end

    External["Внешний API / бэкенд\nНе используется"]

    User --> PhoneUI
    UIKit --> PhoneUI
    PhoneUI --> Flow --> PhoneVM --> Domain --> Repository
    PhoneUI -. визуализация .-> Charts
    Repository --> PhoneDB
    Repository --> Settings
    PhoneDB -. путь к файлу .-> FileSystem
    Repository --> PhoneSync --> WC
    WC <--> WatchVM
    WatchUI --> WatchVM --> WatchDB
    WatchVM --> WC
    PhoneVM -. обновления из локального хранилища .-> PhoneUI
    WatchVM -. обновления из локального хранилища .-> WatchUI
    PhoneSync -. нет сетевого вызова .-> External

    classDef system fill:#DCEEFF,stroke:#2563EB,color:#0F172A;
    classDef external fill:#F3F4F6,stroke:#6B7280,color:#374151,stroke-dasharray: 5 5;
    class Charts,FileSystem,WC system;
    class External external;
```

## Как данные проходят по системе

Пользовательский ввод поступает из SwiftUI во ViewModel, затем в доменный слой и репозиторий. Репозиторий сохраняет данные в локальную SQLite-базу; наблюдение за ней обновляет интерфейс на iPhone и Apple Watch. Изменения попадают в очередь синхронизации и передаются через системный `WatchConnectivity` API, после чего принимающее устройство применяет их в своей локальной базе и подтверждает доставку.

## Инструменты проекта

| Инструмент | Роль в проекте |
| --- | --- |
| **Tuist** | Декларативно описывает модули, их зависимости и генерирует Xcode workspace; включён контроль явных зависимостей между модулями. |
| **Mise** | Фиксирует версии инструментов и предоставляет единые команды для установки зависимостей, генерации workspace, проверки и тестов. |
| **Fastlane** | Запускает стандартизированные проверки качества и тестирования в локальном окружении и CI. |

## Первый запуск

```bash
brew install mise
mise install
mise run generate
open WeightMonitor.xcworkspace
```

Для полной проверки проекта используйте `mise run check`. Mise также предоставляет сокращённые команды: `mise run install` для зависимостей Tuist, `mise run test` для тестов и `mise run clean` для очистки сгенерированных артефактов.
