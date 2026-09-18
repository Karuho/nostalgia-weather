.pragma library

var languageCodes = [
    "en",
    "es",
    "pt",
    "fr",
    "de",
    "it",
    "ja",
    "zh-CN",
    "zh-TW",
    "ko",
    "ru"
]

var languageNames = [
    "English",
    "Español",
    "Português",
    "Français",
    "Deutsch",
    "Italiano",
    "日本語",
    "简体中文",
    "繁體中文",
    "한국어",
    "Русский"
]

var strings = {
    "Today": {
        es: "Hoy",
        pt: "Hoje",
        fr: "Aujourd’hui",
        de: "Heute",
        it: "Oggi",
        ja: "今日",
        "zh-CN": "今天",
        "zh-TW": "今天",
        ko: "오늘",
        ru: "Сегодня"
    },

    "General": {
        es: "General",
        pt: "Geral",
        fr: "Général",
        de: "Allgemein",
        it: "Generale",
        ja: "一般",
        "zh-CN": "常规",
        "zh-TW": "一般",
        ko: "일반",
        ru: "Общие"
    },

    "Location": {
        es: "Ubicación",
        pt: "Localização",
        fr: "Emplacement",
        de: "Standort",
        it: "Posizione",
        ja: "場所",
        "zh-CN": "位置",
        "zh-TW": "位置",
        ko: "위치",
        ru: "Местоположение"
    },

    "Search:": {
        es: "Buscar:",
        pt: "Pesquisar:",
        fr: "Rechercher :",
        de: "Suchen:",
        it: "Cerca:",
        ja: "検索:",
        "zh-CN": "搜索：",
        "zh-TW": "搜尋：",
        ko: "검색:",
        ru: "Поиск:"
    },

    "City, region or postal code": {
        es: "Ciudad, región o código postal",
        pt: "Cidade, região ou código postal",
        fr: "Ville, région ou code postal",
        de: "Stadt, Region oder Postleitzahl",
        it: "Città, regione o codice postale",
        ja: "都市、地域、郵便番号",
        "zh-CN": "城市、地区或邮政编码",
        "zh-TW": "城市、地區或郵遞區號",
        ko: "도시, 지역 또는 우편번호",
        ru: "Город, регион или почтовый индекс"
    },

    "Selected location:": {
        es: "Ubicación seleccionada:",
        pt: "Local selecionado:",
        fr: "Emplacement sélectionné :",
        de: "Ausgewählter Standort:",
        it: "Posizione selezionata:",
        ja: "選択した場所:",
        "zh-CN": "已选位置：",
        "zh-TW": "已選位置：",
        ko: "선택한 위치:",
        ru: "Выбранное местоположение:"
    },

    "Latitude:": {
        es: "Latitud:",
        pt: "Latitude:",
        fr: "Latitude :",
        de: "Breitengrad:",
        it: "Latitudine:",
        ja: "緯度:",
        "zh-CN": "纬度：",
        "zh-TW": "緯度：",
        ko: "위도:",
        ru: "Широта:"
    },

    "Longitude:": {
        es: "Longitud:",
        pt: "Longitude:",
        fr: "Longitude :",
        de: "Längengrad:",
        it: "Longitudine:",
        ja: "経度:",
        "zh-CN": "经度：",
        "zh-TW": "經度：",
        ko: "경도:",
        ru: "Долгота:"
    },

    "Time zone:": {
        es: "Zona horaria:",
        pt: "Fuso horário:",
        fr: "Fuseau horaire :",
        de: "Zeitzone:",
        it: "Fuso orario:",
        ja: "タイムゾーン:",
        "zh-CN": "时区：",
        "zh-TW": "時區：",
        ko: "시간대:",
        ru: "Часовой пояс:"
    },

    "Forecast": {
        es: "Pronóstico",
        pt: "Previsão",
        fr: "Prévisions",
        de: "Vorhersage",
        it: "Previsioni",
        ja: "予報",
        "zh-CN": "天气预报",
        "zh-TW": "天氣預報",
        ko: "예보",
        ru: "Прогноз"
    },

    "Days to show:": {
        es: "Días a mostrar:",
        pt: "Dias a mostrar:",
        fr: "Jours à afficher :",
        de: "Anzuzeigende Tage:",
        it: "Giorni da mostrare:",
        ja: "表示する日数:",
        "zh-CN": "显示天数：",
        "zh-TW": "顯示天數：",
        ko: "표시할 일수:",
        ru: "Количество дней:"
    },

    "3 days": {
        es: "3 días", pt: "3 dias", fr: "3 jours",
        de: "3 Tage", it: "3 giorni", ja: "3日",
        "zh-CN": "3天", "zh-TW": "3天", ko: "3일", ru: "3 дня"
    },

    "5 days": {
        es: "5 días", pt: "5 dias", fr: "5 jours",
        de: "5 Tage", it: "5 giorni", ja: "5日",
        "zh-CN": "5天", "zh-TW": "5天", ko: "5일", ru: "5 дней"
    },

    "7 days": {
        es: "7 días", pt: "7 dias", fr: "7 jours",
        de: "7 Tage", it: "7 giorni", ja: "7日",
        "zh-CN": "7天", "zh-TW": "7天", ko: "7일", ru: "7 дней"
    },

    "10 days": {
        es: "10 días", pt: "10 dias", fr: "10 jours",
        de: "10 Tage", it: "10 giorni", ja: "10日",
        "zh-CN": "10天", "zh-TW": "10天", ko: "10일", ru: "10 дней"
    },

    "16 days": {
        es: "16 días", pt: "16 dias", fr: "16 jours",
        de: "16 Tage", it: "16 giorni", ja: "16日",
        "zh-CN": "16天", "zh-TW": "16天", ko: "16일", ru: "16 дней"
    },

    "30 days": {
        es: "30 días", pt: "30 dias", fr: "30 jours",
        de: "30 Tage", it: "30 giorni", ja: "30日",
        "zh-CN": "30天", "zh-TW": "30天", ko: "30일", ru: "30 дней"
    },

    "Temperature:": {
        es: "Temperatura:",
        pt: "Temperatura:",
        fr: "Température :",
        de: "Temperatur:",
        it: "Temperatura:",
        ja: "気温:",
        "zh-CN": "温度：",
        "zh-TW": "溫度：",
        ko: "온도:",
        ru: "Температура:"
    },

    "Update every:": {
        es: "Actualizar cada:",
        pt: "Atualizar a cada:",
        fr: "Actualiser toutes les :",
        de: "Aktualisieren alle:",
        it: "Aggiorna ogni:",
        ja: "更新間隔:",
        "zh-CN": "更新间隔：",
        "zh-TW": "更新間隔：",
        ko: "업데이트 간격:",
        ru: "Интервал обновления:"
    },

    "Language": {
        es: "Idioma",
        pt: "Idioma",
        fr: "Langue",
        de: "Sprache",
        it: "Lingua",
        ja: "言語",
        "zh-CN": "语言",
        "zh-TW": "語言",
        ko: "언어",
        ru: "Язык"
    },

    "Interface language:": {
        es: "Idioma de la interfaz:",
        pt: "Idioma da interface:",
        fr: "Langue de l’interface :",
        de: "Oberflächensprache:",
        it: "Lingua dell'interfaccia:",
        ja: "インターフェース言語:",
        "zh-CN": "界面语言：",
        "zh-TW": "介面語言：",
        ko: "인터페이스 언어:",
        ru: "Язык интерфейса:"
    },

    "English is the default language.": {
        es: "El inglés es el idioma predeterminado.",
        pt: "O inglês é o idioma padrão.",
        fr: "L’anglais est la langue par défaut.",
        de: "Englisch ist die Standardsprache.",
        it: "L'inglese è la lingua predefinita.",
        ja: "英語が既定の言語です。",
        "zh-CN": "英语是默认语言。",
        "zh-TW": "英文是預設語言。",
        ko: "영어가 기본 언어입니다.",
        ru: "Английский язык используется по умолчанию."
    },

    "Visible information": {
        es: "Información visible",
        pt: "Informações visíveis",
        fr: "Informations visibles",
        de: "Sichtbare Informationen",
        it: "Informazioni visibili",
        ja: "表示する情報",
        "zh-CN": "显示信息",
        "zh-TW": "顯示資訊",
        ko: "표시 정보",
        ru: "Отображаемая информация"
    },

    "Date": {
        es: "Fecha", pt: "Data", fr: "Date", de: "Datum",
        it: "Data", ja: "日付", "zh-CN": "日期",
        "zh-TW": "日期", ko: "날짜", ru: "Дата"
    },

    "Feels-like temperature": {
        es: "Sensación térmica",
        pt: "Sensação térmica",
        fr: "Température ressentie",
        de: "Gefühlte Temperatur",
        it: "Temperatura percepita",
        ja: "体感温度",
        "zh-CN": "体感温度",
        "zh-TW": "體感溫度",
        ko: "체감 온도",
        ru: "Ощущаемая температура"
    },

    "Precipitation probability": {
        es: "Probabilidad de precipitación",
        pt: "Probabilidade de precipitação",
        fr: "Probabilité de précipitations",
        de: "Niederschlagswahrscheinlichkeit",
        it: "Probabilità di precipitazioni",
        ja: "降水確率",
        "zh-CN": "降水概率",
        "zh-TW": "降水機率",
        ko: "강수 확률",
        ru: "Вероятность осадков"
    },

    "UV index": {
        es: "Índice UV",
        pt: "Índice UV",
        fr: "Indice UV",
        de: "UV-Index",
        it: "Indice UV",
        ja: "UV指数",
        "zh-CN": "紫外线指数",
        "zh-TW": "紫外線指數",
        ko: "자외선 지수",
        ru: "УФ-индекс"
    },

    "Sunrise and sunset": {
        es: "Amanecer y atardecer",
        pt: "Nascer e pôr do sol",
        fr: "Lever et coucher du soleil",
        de: "Sonnenaufgang und -untergang",
        it: "Alba e tramonto",
        ja: "日の出と日の入り",
        "zh-CN": "日出和日落",
        "zh-TW": "日出與日落",
        ko: "일출과 일몰",
        ru: "Восход и закат"
    },

    "Air quality": {
        es: "Calidad del aire",
        pt: "Qualidade do ar",
        fr: "Qualité de l’air",
        de: "Luftqualität",
        it: "Qualità dell'aria",
        ja: "大気質",
        "zh-CN": "空气质量",
        "zh-TW": "空氣品質",
        ko: "대기질",
        ru: "Качество воздуха"
    },

    "Atmospheric dust": {
        es: "Polvo atmosférico",
        pt: "Poeira atmosférica",
        fr: "Poussière atmosphérique",
        de: "Atmosphärischer Staub",
        it: "Polvere atmosferica",
        ja: "大気中の粉じん",
        "zh-CN": "大气尘埃",
        "zh-TW": "大氣塵埃",
        ko: "대기 먼지",
        ru: "Атмосферная пыль"
    },

    "Moon phase": {
        es: "Fase lunar",
        pt: "Fase da Lua",
        fr: "Phase de la Lune",
        de: "Mondphase",
        it: "Fase lunare",
        ja: "月相",
        "zh-CN": "月相",
        "zh-TW": "月相",
        ko: "달의 위상",
        ru: "Фаза Луны"
    },

    "Daily precipitation below forecast": {
        es: "Precipitación diaria bajo el pronóstico",
        pt: "Precipitação diária sob a previsão",
        fr: "Précipitations quotidiennes sous les prévisions",
        de: "Täglicher Niederschlag unter der Vorhersage",
        it: "Precipitazioni giornaliere sotto le previsioni",
        ja: "予報の下に日別降水確率を表示",
        "zh-CN": "在预报下方显示每日降水概率",
        "zh-TW": "在預報下方顯示每日降水機率",
        ko: "예보 아래 일별 강수 확률 표시",
        ru: "Осадки по дням под прогнозом"
    },

    "Clear": {
        es: "Despejado", pt: "Céu limpo", fr: "Dégagé",
        de: "Klar", it: "Sereno", ja: "快晴",
        "zh-CN": "晴朗", "zh-TW": "晴朗", ko: "맑음", ru: "Ясно"
    },

    "Mainly clear": {
        es: "Mayormente despejado", pt: "Predominantemente limpo",
        fr: "Globalement dégagé", de: "Überwiegend klar",
        it: "Prevalentemente sereno", ja: "おおむね晴れ",
        "zh-CN": "大部晴朗", "zh-TW": "大致晴朗",
        ko: "대체로 맑음", ru: "Преимущественно ясно"
    },

    "Partly cloudy": {
        es: "Parcialmente nublado", pt: "Parcialmente nublado",
        fr: "Partiellement nuageux", de: "Teilweise bewölkt",
        it: "Parzialmente nuvoloso", ja: "晴れ時々曇り",
        "zh-CN": "局部多云", "zh-TW": "局部多雲",
        ko: "구름 조금", ru: "Переменная облачность"
    },

    "Cloudy": {
        es: "Nublado", pt: "Nublado", fr: "Nuageux",
        de: "Bewölkt", it: "Nuvoloso", ja: "曇り",
        "zh-CN": "多云", "zh-TW": "多雲", ko: "흐림", ru: "Облачно"
    },

    "Fog": {
        es: "Niebla", pt: "Nevoeiro", fr: "Brouillard",
        de: "Nebel", it: "Nebbia", ja: "霧",
        "zh-CN": "雾", "zh-TW": "霧", ko: "안개", ru: "Туман"
    },

    "Drizzle": {
        es: "Llovizna", pt: "Garoa", fr: "Bruine",
        de: "Nieselregen", it: "Pioviggine", ja: "霧雨",
        "zh-CN": "毛毛雨", "zh-TW": "毛毛雨", ko: "이슬비", ru: "Морось"
    },

    "Rain": {
        es: "Lluvia", pt: "Chuva", fr: "Pluie",
        de: "Regen", it: "Pioggia", ja: "雨",
        "zh-CN": "雨", "zh-TW": "雨", ko: "비", ru: "Дождь"
    },

    "Snow": {
        es: "Nieve", pt: "Neve", fr: "Neige",
        de: "Schnee", it: "Neve", ja: "雪",
        "zh-CN": "雪", "zh-TW": "雪", ko: "눈", ru: "Снег"
    },

    "Rain showers": {
        es: "Chubascos", pt: "Pancadas de chuva",
        fr: "Averses", de: "Regenschauer",
        it: "Rovesci", ja: "にわか雨",
        "zh-CN": "阵雨", "zh-TW": "陣雨",
        ko: "소나기", ru: "Ливни"
    },

    "Snow showers": {
        es: "Chubascos de nieve", pt: "Pancadas de neve",
        fr: "Averses de neige", de: "Schneeschauer",
        it: "Rovesci di neve", ja: "にわか雪",
        "zh-CN": "阵雪", "zh-TW": "陣雪",
        ko: "눈 소나기", ru: "Снежные заряды"
    },

    "Thunderstorm": {
        es: "Tormenta", pt: "Trovoada", fr: "Orage",
        de: "Gewitter", it: "Temporale", ja: "雷雨",
        "zh-CN": "雷暴", "zh-TW": "雷暴",
        ko: "뇌우", ru: "Гроза"
    },

    "No data": {
        es: "Sin datos", pt: "Sem dados", fr: "Aucune donnée",
        de: "Keine Daten", it: "Nessun dato", ja: "データなし",
        "zh-CN": "无数据", "zh-TW": "無資料",
        ko: "데이터 없음", ru: "Нет данных"
    },

    "Feels like": {
        es: "Sensación", pt: "Sensação", fr: "Ressenti",
        de: "Gefühlt", it: "Percepita", ja: "体感",
        "zh-CN": "体感", "zh-TW": "體感",
        ko: "체감", ru: "Ощущается как"
    },

    "Precipitation probability today": {
        es: "Probabilidad de precipitación hoy",
        pt: "Probabilidade de precipitação hoje",
        fr: "Probabilité de précipitations aujourd’hui",
        de: "Niederschlagswahrscheinlichkeit heute",
        it: "Probabilità di precipitazioni oggi",
        ja: "今日の降水確率",
        "zh-CN": "今日降水概率",
        "zh-TW": "今日降水機率",
        ko: "오늘의 강수 확률",
        ru: "Вероятность осадков сегодня"
    },

    "Maximum UV index today": {
        es: "Índice UV máximo de hoy",
        pt: "Índice UV máximo de hoje",
        fr: "Indice UV maximal aujourd’hui",
        de: "Maximaler UV-Index heute",
        it: "Indice UV massimo di oggi",
        ja: "今日の最大UV指数",
        "zh-CN": "今日最高紫外线指数",
        "zh-TW": "今日最高紫外線指數",
        ko: "오늘의 최대 자외선 지수",
        ru: "Максимальный УФ-индекс сегодня"
    },

    "Sunrise": {
        es: "Salida del sol / Amanecer",
        pt: "Nascer do sol",
        fr: "Lever du soleil",
        de: "Sonnenaufgang",
        it: "Alba",
        ja: "日の出",
        "zh-CN": "日出",
        "zh-TW": "日出",
        ko: "일출",
        ru: "Восход"
    },

    "Sunset": {
        es: "Puesta del sol / Atardecer",
        pt: "Pôr do sol",
        fr: "Coucher du soleil",
        de: "Sonnenuntergang",
        it: "Tramonto",
        ja: "日の入り",
        "zh-CN": "日落",
        "zh-TW": "日落",
        ko: "일몰",
        ru: "Закат"
    },

    "Air quality (AQI): overall air pollution index": {
        es: "Calidad del aire (AQI): índice general de contaminación atmosférica",
        pt: "Qualidade do ar (AQI): índice geral de poluição do ar",
        fr: "Qualité de l’air (AQI) : indice global de pollution",
        de: "Luftqualität (AQI): allgemeiner Luftverschmutzungsindex",
        it: "Qualità dell'aria (AQI): indice generale di inquinamento",
        ja: "大気質 (AQI): 総合的な大気汚染指数",
        "zh-CN": "空气质量 (AQI)：综合空气污染指数",
        "zh-TW": "空氣品質 (AQI)：綜合空氣污染指數",
        ko: "대기질 (AQI): 종합 대기 오염 지수",
        ru: "Качество воздуха (AQI): общий индекс загрязнения"
    },

    "Atmospheric dust concentration": {
        es: "Concentración de polvo atmosférico",
        pt: "Concentração de poeira atmosférica",
        fr: "Concentration de poussière atmosphérique",
        de: "Konzentration atmosphärischen Staubs",
        it: "Concentrazione di polvere atmosferica",
        ja: "大気中の粉じん濃度",
        "zh-CN": "大气尘埃浓度",
        "zh-TW": "大氣塵埃濃度",
        ko: "대기 먼지 농도",
        ru: "Концентрация атмосферной пыли"
    },

    "Current Moon phase": {
        es: "Fase actual de la Luna",
        pt: "Fase atual da Lua",
        fr: "Phase actuelle de la Lune",
        de: "Aktuelle Mondphase",
        it: "Fase lunare attuale",
        ja: "現在の月相",
        "zh-CN": "当前月相",
        "zh-TW": "目前月相",
        ko: "현재 달의 위상",
        ru: "Текущая фаза Луны"
    },

    "New moon": {
        es: "Luna nueva", pt: "Lua nova", fr: "Nouvelle lune",
        de: "Neumond", it: "Luna nuova", ja: "新月",
        "zh-CN": "新月", "zh-TW": "新月", ko: "삭", ru: "Новолуние"
    },

    "Waxing crescent": {
        es: "Creciente", pt: "Lua crescente",
        fr: "Premier croissant", de: "Zunehmende Sichel",
        it: "Luna crescente", ja: "三日月",
        "zh-CN": "娥眉月", "zh-TW": "眉月",
        ko: "초승달", ru: "Растущий серп"
    },

    "First quarter": {
        es: "Cuarto creciente", pt: "Quarto crescente",
        fr: "Premier quartier", de: "Erstes Viertel",
        it: "Primo quarto", ja: "上弦の月",
        "zh-CN": "上弦月", "zh-TW": "上弦月",
        ko: "상현달", ru: "Первая четверть"
    },

    "Waxing gibbous": {
        es: "Gibosa creciente", pt: "Gibosa crescente",
        fr: "Gibbeuse croissante", de: "Zunehmender Mond",
        it: "Gibbosa crescente", ja: "満ちていく月",
        "zh-CN": "盈凸月", "zh-TW": "盈凸月",
        ko: "차오르는 달", ru: "Растущая Луна"
    },

    "Full moon": {
        es: "Luna llena", pt: "Lua cheia", fr: "Pleine lune",
        de: "Vollmond", it: "Luna piena", ja: "満月",
        "zh-CN": "满月", "zh-TW": "滿月", ko: "보름달", ru: "Полнолуние"
    },

    "Waning gibbous": {
        es: "Gibosa menguante", pt: "Gibosa minguante",
        fr: "Gibbeuse décroissante", de: "Abnehmender Mond",
        it: "Gibbosa calante", ja: "欠けていく月",
        "zh-CN": "亏凸月", "zh-TW": "虧凸月",
        ko: "기우는 달", ru: "Убывающая Луна"
    },

    "Last quarter": {
        es: "Cuarto menguante", pt: "Quarto minguante",
        fr: "Dernier quartier", de: "Letztes Viertel",
        it: "Ultimo quarto", ja: "下弦の月",
        "zh-CN": "下弦月", "zh-TW": "下弦月",
        ko: "하현달", ru: "Последняя четверть"
    },

    "Waning crescent": {
        es: "Menguante", pt: "Lua minguante",
        fr: "Dernier croissant", de: "Abnehmende Sichel",
        it: "Luna calante", ja: "有明月",
        "zh-CN": "残月", "zh-TW": "殘月",
        ko: "그믐달", ru: "Убывающий серп"
    },

    "Good": {
        es: "Bueno", pt: "Bom", fr: "Bon", de: "Gut",
        it: "Buona", ja: "良好", "zh-CN": "良好",
        "zh-TW": "良好", ko: "좋음", ru: "Хорошо"
    },

    "Moderate": {
        es: "Moderado", pt: "Moderado", fr: "Modéré",
        de: "Mäßig", it: "Moderata", ja: "普通",
        "zh-CN": "中等", "zh-TW": "中等",
        ko: "보통", ru: "Умеренно"
    },

    "Sensitive groups": {
        es: "Grupos sensibles",
        pt: "Grupos sensíveis",
        fr: "Groupes sensibles",
        de: "Empfindliche Gruppen",
        it: "Gruppi sensibili",
        ja: "敏感な人には注意",
        "zh-CN": "敏感人群",
        "zh-TW": "敏感族群",
        ko: "민감군",
        ru: "Для чувствительных групп"
    },

    "Unhealthy": {
        es: "Malo", pt: "Ruim", fr: "Mauvais",
        de: "Ungesund", it: "Insalubre", ja: "健康に悪い",
        "zh-CN": "不健康", "zh-TW": "不健康",
        ko: "나쁨", ru: "Вредно"
    },

    "Very unhealthy": {
        es: "Muy malo", pt: "Muito ruim", fr: "Très mauvais",
        de: "Sehr ungesund", it: "Molto insalubre",
        ja: "非常に健康に悪い", "zh-CN": "非常不健康",
        "zh-TW": "非常不健康", ko: "매우 나쁨",
        ru: "Очень вредно"
    },

    "Hazardous": {
        es: "Peligroso", pt: "Perigoso", fr: "Dangereux",
        de: "Gefährlich", it: "Pericolosa", ja: "危険",
        "zh-CN": "危险", "zh-TW": "危險",
        ko: "위험", ru: "Опасно"
    },

    "Settings": {
        es: "Configuración", pt: "Configurações",
        fr: "Paramètres", de: "Einstellungen",
        it: "Impostazioni", ja: "設定",
        "zh-CN": "设置", "zh-TW": "設定",
        ko: "설정", ru: "Настройки"
    },

    "Refresh": {
        es: "Actualizar", pt: "Atualizar",
        fr: "Actualiser", de: "Aktualisieren",
        it: "Aggiorna", ja: "更新",
        "zh-CN": "刷新", "zh-TW": "重新整理",
        ko: "새로고침", ru: "Обновить"
    },

    "Location search failed.": {
        es: "No se pudo buscar la ubicación.",
        pt: "Não foi possível pesquisar a localização.",
        fr: "La recherche de l’emplacement a échoué.",
        de: "Standortsuche fehlgeschlagen.",
        it: "Ricerca della posizione non riuscita.",
        ja: "場所を検索できませんでした。",
        "zh-CN": "位置搜索失败。",
        "zh-TW": "位置搜尋失敗。",
        ko: "위치 검색에 실패했습니다.",
        ru: "Не удалось выполнить поиск местоположения."
    },

    "No locations found.": {
        es: "No se encontraron ubicaciones.",
        pt: "Nenhum local encontrado.",
        fr: "Aucun emplacement trouvé.",
        de: "Keine Standorte gefunden.",
        it: "Nessuna posizione trovata.",
        ja: "場所が見つかりませんでした。",
        "zh-CN": "未找到位置。",
        "zh-TW": "找不到位置。",
        ko: "위치를 찾을 수 없습니다.",
        ru: "Местоположения не найдены."
    },

    "Invalid location response.": {
        es: "La respuesta de ubicación no es válida.",
        pt: "A resposta de localização é inválida.",
        fr: "La réponse de localisation est invalide.",
        de: "Ungültige Standortantwort.",
        it: "Risposta di localizzazione non valida.",
        ja: "場所の応答が無効です。",
        "zh-CN": "位置响应无效。",
        "zh-TW": "位置回應無效。",
        ko: "잘못된 위치 응답입니다.",
        ru: "Некорректный ответ местоположения."
    },

    "Invalid coordinates": {
        es: "Coordenadas inválidas",
        pt: "Coordenadas inválidas",
        fr: "Coordonnées invalides",
        de: "Ungültige Koordinaten",
        it: "Coordinate non valide",
        ja: "無効な座標",
        "zh-CN": "坐标无效",
        "zh-TW": "座標無效",
        ko: "잘못된 좌표",
        ru: "Некорректные координаты"
    },

    "Unable to update weather": {
        es: "No se pudo actualizar el clima",
        pt: "Não foi possível atualizar o clima",
        fr: "Impossible de mettre à jour la météo",
        de: "Wetter konnte nicht aktualisiert werden",
        it: "Impossibile aggiornare il meteo",
        ja: "天気を更新できませんでした",
        "zh-CN": "无法更新天气",
        "zh-TW": "無法更新天氣",
        ko: "날씨를 업데이트할 수 없습니다",
        ru: "Не удалось обновить погоду"
    },

    "Invalid weather response": {
        es: "Respuesta meteorológica inválida",
        pt: "Resposta meteorológica inválida",
        fr: "Réponse météo invalide",
        de: "Ungültige Wetterantwort",
        it: "Risposta meteo non valida",
        ja: "天気情報の応答が無効です",
        "zh-CN": "天气响应无效",
        "zh-TW": "天氣回應無效",
        ko: "잘못된 날씨 응답입니다",
        ru: "Некорректный ответ погоды"
    },
    "Use current location": {
        es: "Usar ubicación actual",
        pt: "Usar localização atual",
        fr: "Utiliser la position actuelle",
        de: "Aktuellen Standort verwenden",
        it: "Usa posizione attuale",
        ja: "現在地を使用",
        "zh-CN": "使用当前位置",
        "zh-TW": "使用目前位置",
        ko: "현재 위치 사용",
        ru: "Использовать текущее местоположение"
    },

    "Detecting current location…": {
        es: "Detectando ubicación actual…",
        pt: "Detectando localização atual…",
        fr: "Détection de la position actuelle…",
        de: "Aktueller Standort wird ermittelt…",
        it: "Rilevamento della posizione attuale…",
        ja: "現在地を取得しています…",
        "zh-CN": "正在检测当前位置…",
        "zh-TW": "正在偵測目前位置…",
        ko: "현재 위치를 확인하는 중…",
        ru: "Определение текущего местоположения…"
    },

    "Current location": {
        es: "Ubicación actual",
        pt: "Localização atual",
        fr: "Position actuelle",
        de: "Aktueller Standort",
        it: "Posizione attuale",
        ja: "現在地",
        "zh-CN": "当前位置",
        "zh-TW": "目前位置",
        ko: "현재 위치",
        ru: "Текущее местоположение"
    },

    "Location services are unavailable.": {
        es: "Los servicios de ubicación no están disponibles.",
        pt: "Os serviços de localização não estão disponíveis.",
        fr: "Les services de localisation ne sont pas disponibles.",
        de: "Standortdienste sind nicht verfügbar.",
        it: "I servizi di localizzazione non sono disponibili.",
        ja: "位置情報サービスを利用できません。",
        "zh-CN": "位置服务不可用。",
        "zh-TW": "定位服務無法使用。",
        ko: "위치 서비스를 사용할 수 없습니다.",
        ru: "Службы геолокации недоступны."
    },

    "Location access was denied.": {
        es: "Se denegó el acceso a la ubicación.",
        pt: "O acesso à localização foi negado.",
        fr: "L’accès à la localisation a été refusé.",
        de: "Der Zugriff auf den Standort wurde verweigert.",
        it: "L'accesso alla posizione è stato negato.",
        ja: "位置情報へのアクセスが拒否されました。",
        "zh-CN": "位置访问被拒绝。",
        "zh-TW": "定位存取遭到拒絕。",
        ko: "위치 접근이 거부되었습니다.",
        ru: "Доступ к геолокации запрещён."
    },

    "Location request timed out.": {
        es: "Se agotó el tiempo para obtener la ubicación.",
        pt: "A solicitação de localização expirou.",
        fr: "La demande de localisation a expiré.",
        de: "Zeitüberschreitung bei der Standortabfrage.",
        it: "La richiesta della posizione è scaduta.",
        ja: "位置情報の取得がタイムアウトしました。",
        "zh-CN": "位置请求超时。",
        "zh-TW": "定位要求逾時。",
        ko: "위치 요청 시간이 초과되었습니다.",
        ru: "Истекло время ожидания геолокации."
    },

    "Could not determine the current time zone.": {
        es: "No se pudo determinar la zona horaria actual.",
        pt: "Não foi possível determinar o fuso horário atual.",
        fr: "Impossible de déterminer le fuseau horaire actuel.",
        de: "Die aktuelle Zeitzone konnte nicht ermittelt werden.",
        it: "Impossibile determinare il fuso orario corrente.",
        ja: "現在のタイムゾーンを判定できませんでした。",
        "zh-CN": "无法确定当前时区。",
        "zh-TW": "無法判斷目前時區。",
        ko: "현재 시간대를 확인할 수 없습니다.",
        ru: "Не удалось определить текущий часовой пояс."
    },

    "Location detected. Press Apply to save it.": {
        es: "Ubicación detectada. Pulsa Aplicar para guardarla.",
        pt: "Localização detectada. Pressione Aplicar para salvar.",
        fr: "Position détectée. Cliquez sur Appliquer pour l’enregistrer.",
        de: "Standort erkannt. Zum Speichern auf Anwenden klicken.",
        it: "Posizione rilevata. Premi Applica per salvarla.",
        ja: "現在地を取得しました。適用を押して保存してください。",
        "zh-CN": "已检测到位置。按“应用”保存。",
        "zh-TW": "已偵測到位置。按「套用」儲存。",
        ko: "위치를 확인했습니다. 적용을 눌러 저장하세요.",
        ru: "Местоположение определено. Нажмите «Применить», чтобы сохранить."
    }

}

function t(language, english, spanishFallback) {
    if (!language || language === "en")
        return english

    if (language === "es" && spanishFallback)
        return spanishFallback

    var entry = strings[english]

    if (entry && entry[language])
        return entry[language]

    /*
     * Fail closed to English so a missing translation
     * never produces blank/undefined UI.
     */
    return english
}

function geocodingLanguage(language) {
    if (!language)
        return "en"

    var separator = language.indexOf("-")

    if (separator > 0)
        return language.substring(0, separator)

    return language
}
