# get_weather.ps1
# 서울 영등포구 날씨 + 미세먼지 자동 수집 (API 키 불필요 - Open-Meteo 사용)
# 저장 위치: 이 스크립트와 같은 폴더의 weather.txt

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$OutputFile = Join-Path $ScriptDir "weather.txt"

# 영등포구 좌표
$Lat = 37.5264
$Lon = 126.8964

$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ── 1. 날씨 데이터 (Open-Meteo 무료 API) ──────────────────────────────────
$WeatherUrl = "https://api.open-meteo.com/v1/forecast" +
    "?latitude=$Lat&longitude=$Lon" +
    "&current=temperature_2m,relative_humidity_2m,apparent_temperature," +
    "precipitation,weather_code,wind_speed_10m" +
    "&timezone=Asia%2FSeoul"

# ── 2. 대기질 데이터 (Open-Meteo Air Quality 무료 API) ─────────────────────
$AqUrl = "https://air-quality-api.open-meteo.com/v1/air-quality" +
    "?latitude=$Lat&longitude=$Lon" +
    "&current=pm10,pm2_5,us_aqi" +
    "&timezone=Asia%2FSeoul"

function Get-WeatherDesc($Code) {
    switch ($Code) {
        0       { return "맑음" }
        1       { return "대체로 맑음" }
        2       { return "부분적으로 흐림" }
        3       { return "흐림" }
        {$_ -in 45,48} { return "안개" }
        {$_ -in 51,53,55} { return "이슬비" }
        {$_ -in 61,63,65} { return "비" }
        {$_ -in 71,73,75} { return "눈" }
        {$_ -in 80,81,82} { return "소나기" }
        {$_ -in 95,96,99} { return "뇌우" }
        default { return "코드 $Code" }
    }
}

function Get-PM25Grade($Val) {
    if     ($Val -lt 15)  { return "좋음 [GREEN]" }
    elseif ($Val -lt 35)  { return "보통 [YELLOW]" }
    elseif ($Val -lt 75)  { return "나쁨 [ORANGE]" }
    else                  { return "매우나쁨 [RED]" }
}

function Get-PM10Grade($Val) {
    if     ($Val -lt 30)  { return "좋음 [GREEN]" }
    elseif ($Val -lt 80)  { return "보통 [YELLOW]" }
    elseif ($Val -lt 150) { return "나쁨 [ORANGE]" }
    else                  { return "매우나쁨 [RED]" }
}

try {
    $W = Invoke-RestMethod -Uri $WeatherUrl -UseBasicParsing
    $A = Invoke-RestMethod -Uri $AqUrl      -UseBasicParsing

    $Temp        = $W.current.temperature_2m
    $FeelsLike   = $W.current.apparent_temperature
    $Humidity    = $W.current.relative_humidity_2m
    $Precip      = $W.current.precipitation
    $Wind        = $W.current.wind_speed_10m
    $WCode       = $W.current.weather_code

    $PM25        = [math]::Round($A.current.pm2_5, 1)
    $PM10        = [math]::Round($A.current.pm10,  1)
    $AQI         = $A.current.us_aqi

    $WeatherDesc = Get-WeatherDesc $WCode
    $PM25Grade   = Get-PM25Grade  $PM25
    $PM10Grade   = Get-PM10Grade  $PM10

    $Content = @"
========================================
  서울 영등포구 날씨 & 미세먼지 정보
  수집 일시: $Timestamp
========================================

[날씨]
  상태   : $WeatherDesc
  기온   : ${Temp}도C  (체감 ${FeelsLike}도C)
  습도   : ${Humidity}%
  강수량 : ${Precip}mm
  풍속   : ${Wind} km/h

[미세먼지]
  PM2.5  : ${PM25} ug/m3  -> $PM25Grade
  PM10   : ${PM10} ug/m3  -> $PM10Grade
  AQI    : $AQI (미국 기준)

[기준표]
  PM2.5: 좋음<15 / 보통<35 / 나쁨<75 / 매우나쁨>=75
  PM10 : 좋음<30 / 보통<80 / 나쁨<150 / 매우나쁨>=150

========================================
"@

    [System.IO.File]::WriteAllText($OutputFile, $Content, [System.Text.Encoding]::UTF8)
    Write-Host "저장 완료: $OutputFile ($Timestamp)"

} catch {
    $ErrContent = "[$Timestamp] 오류 발생: $_`r`n"
    [System.IO.File]::AppendAllText($OutputFile, $ErrContent, [System.Text.Encoding]::UTF8)
    Write-Host "오류: $_"
    exit 1
}
