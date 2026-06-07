#requires -Version 5.1
<#
.SYNOPSIS
    Настраивает production-signing для GitHub Releases.

.DESCRIPTION
    Делает в одно прогоняние:
      1. Генерирует Android release keystore через keytool.
      2. Кодирует keystore в base64.
      3. Загружает 4 значения в GitHub Secrets через gh CLI (или открывает UI с подсказками,
         если gh недоступен).

    Keystore сохраняется в %USERPROFILE%\.android\water-analyzer-release.jks — вне репо,
    не попадает в git (см. .gitignore). Бэкап делай сразу — если потеряешь файл или пароль,
    выпускать обновления приложения с тем же applicationId больше не получится.

.PARAMETER KeystorePath
    Куда сохранить keystore. Дефолт: %USERPROFILE%\.android\water-analyzer-release.jks

.PARAMETER Alias
    Имя ключа внутри keystore. Дефолт: water-analyzer

.PARAMETER ValidityDays
    Сколько дней действителен сертификат. Дефолт: 10000 (≈27 лет).

.PARAMETER DistinguishedName
    DN сертификата в формате keytool (CN, OU, O, L, ST, C). Дефолт — заглушка
    для personal-проекта. Менять не обязательно — для приватного распространения это
    не имеет значения; для Play Store лучше указать реальные данные.

.EXAMPLE
    .\tools\setup-release-signing.ps1
    Запросит пароль, сгенерирует keystore, загрузит в GitHub.
#>
[CmdletBinding()]
param(
    [string]$KeystorePath = (Join-Path $env:USERPROFILE ".android\water-analyzer-release.jks"),
    [string]$Alias = "water-analyzer",
    [int]$ValidityDays = 10000,
    [string]$DistinguishedName = "CN=Water Analyzer, OU=Personal, O=SmartHome, L=Moscow, ST=Moscow, C=RU"
)

$ErrorActionPreference = "Stop"

function Write-Step($msg) {
    Write-Host ""
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Write-Ok($msg)    { Write-Host "    [OK] $msg" -ForegroundColor Green }
function Write-Warn($msg)  { Write-Host "    [!]  $msg" -ForegroundColor Yellow }
function Write-Err($msg)   { Write-Host "    [X]  $msg" -ForegroundColor Red }

# --- Проверка инструментов --------------------------------------------------

Write-Step "Проверка инструментов"
$keytool = Get-Command keytool -ErrorAction SilentlyContinue
if (-not $keytool) {
    Write-Err "keytool не найден. Поставь JDK (или Android Studio) и проверь PATH."
    exit 1
}
Write-Ok "keytool: $($keytool.Source)"

$gh = Get-Command gh -ErrorAction SilentlyContinue
$useGh = $false
if ($gh) {
    # gh auth status пишет результат в stderr (даже когда всё ок) — обходим NativeCommandError.
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    & gh auth status 2>&1 | Out-Null
    $ghAuthExit = $LASTEXITCODE
    $ErrorActionPreference = $prevPref

    if ($ghAuthExit -eq 0) {
        $useGh = $true
        Write-Ok "gh CLI: авторизован, secrets зальём автоматически"
    } else {
        Write-Warn "gh CLI установлен, но не авторизован. Запусти: gh auth login"
        Write-Warn "(или вручную скопируем secrets через UI ниже)"
    }
} else {
    Write-Warn "gh CLI не установлен. Поставить: winget install GitHub.cli"
    Write-Warn "(скрипт продолжит работу, secrets потом скопируешь вручную через UI)"
}

# --- Запрос пароля ----------------------------------------------------------

Write-Step "Пароль для keystore"
Write-Host "Используется один и тот же пароль для storePassword и keyPassword"
Write-Host "(минимум 6 символов; рекомендуется генератор паролей)"
Write-Host ""

$pwd1 = Read-Host "Пароль" -AsSecureString
$pwd2 = Read-Host "Повтори пароль" -AsSecureString

$plain1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd1))
$plain2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd2))

if ($plain1 -ne $plain2) {
    Write-Err "Пароли не совпадают"
    exit 1
}
if ($plain1.Length -lt 6) {
    Write-Err "Пароль слишком короткий (нужно минимум 6 символов)"
    exit 1
}

$password = $plain1

# --- Создание keystore ------------------------------------------------------

Write-Step "Создание keystore"
$keystoreDir = Split-Path -Parent $KeystorePath
if (-not (Test-Path $keystoreDir)) {
    New-Item -ItemType Directory -Path $keystoreDir -Force | Out-Null
}

if (Test-Path $KeystorePath) {
    $resp = Read-Host "Файл $KeystorePath уже существует. Перезаписать? (нет = выход) [y/N]"
    if ($resp -notmatch '^[yY]') {
        Write-Err "Прерывание. Удали или укажи -KeystorePath другой."
        exit 1
    }
    Remove-Item $KeystorePath -Force
}

Write-Host "Путь:    $KeystorePath"
Write-Host "Alias:   $Alias"
Write-Host "Срок:    $ValidityDays дней"
Write-Host ""

# keytool пишет диагностику в stderr ("Generating 2,048 bit RSA key pair..."), и при
# $ErrorActionPreference = "Stop" PowerShell 5.1 трактует stderr-вывод как NativeCommandError
# и прерывает скрипт ДО завершения keytool. Поэтому локально переключаемся на Continue
# и смотрим на $LASTEXITCODE — это единственный надёжный индикатор успеха внешнего exe.
$prevPref = $ErrorActionPreference
$ErrorActionPreference = "Continue"
$keytoolOutput = & keytool -genkey -v `
    -keystore $KeystorePath `
    -keyalg RSA -keysize 2048 -validity $ValidityDays `
    -alias $Alias `
    -storepass $password -keypass $password `
    -dname $DistinguishedName 2>&1
$keytoolExit = $LASTEXITCODE
$ErrorActionPreference = $prevPref

if ($keytoolExit -ne 0) {
    Write-Err "keytool вернул код $keytoolExit"
    $keytoolOutput | Out-String | Write-Host
    exit 1
}
if (-not (Test-Path $KeystorePath)) {
    Write-Err "keytool вернул код 0, но файл $KeystorePath не создан (?)"
    exit 1
}
$sizeKb = [Math]::Round((Get-Item $KeystorePath).Length / 1024, 1)
Write-Ok "keystore создан, $sizeKb KB"

# --- Base64 кодирование -----------------------------------------------------

Write-Step "Кодирование в base64"
$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($KeystorePath))
Write-Ok "base64: $($base64.Length) символов"

# --- Загрузка secrets -------------------------------------------------------

$secrets = @{
    ANDROID_KEYSTORE_BASE64    = $base64
    ANDROID_KEYSTORE_PASSWORD  = $password
    ANDROID_KEY_ALIAS          = $Alias
    ANDROID_KEY_PASSWORD       = $password
}

if ($useGh) {
    Write-Step "Загрузка secrets через gh"

    # gh может писать прогресс/предупреждения в stderr — обходим NativeCommandError так же,
    # как для keytool. Все вызовы gh обёрнуты в локальное Continue.
    $prevPref = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    $repo = ""
    try {
        $repo = (& gh repo view --json nameWithOwner --jq .nameWithOwner 2>$null | Out-String).Trim()
    } catch { }
    if (-not $repo) {
        $ErrorActionPreference = $prevPref
        Write-Err "gh не смог определить репозиторий. Запусти скрипт из корня репо."
        Write-Err "Или укажи вручную: gh secret set NAME -R owner/repo"
        exit 1
    }
    Write-Host "Репозиторий: $repo"

    $failed = 0
    foreach ($name in $secrets.Keys) {
        $value = $secrets[$name]
        # Передаём значение через stdin, чтобы оно не светилось в command line process'а.
        $value | & gh secret set $name -R $repo 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "$name -> загружен"
        } else {
            Write-Err "$name -> не удалось загрузить (код $LASTEXITCODE)"
            $failed++
        }
    }

    $ErrorActionPreference = $prevPref

    Write-Step "Готово"
    if ($failed -eq 0) {
        Write-Ok "Все 4 secret загружены в $repo"
        Write-Ok "Следующий релиз (push тега v*) подпишется production-ключом"
    } else {
        Write-Err "$failed secret(s) не загружены — проверь вывод выше"
        Write-Warn "Можешь загрузить вручную через UI: https://github.com/$repo/settings/secrets/actions"
    }
} else {
    Write-Step "Ручная загрузка через GitHub UI"

    # Кладём base64 в буфер обмена, чтобы пользователь сразу мог вставить.
    Set-Clipboard -Value $base64
    Write-Ok "ANDROID_KEYSTORE_BASE64 (длинная строка) положен в буфер обмена"

    # Пытаемся определить owner/repo через git remote, чтобы сразу дать рабочую ссылку.
    $secretsUrl = "https://github.com/<owner>/SmartHomeWaterAnalyzer/settings/secrets/actions"
    try {
        $remoteUrl = & git config --get remote.origin.url 2>$null
        if ($remoteUrl -match '[:/]([^/:]+)/([^/]+?)(\.git)?$') {
            $owner = $Matches[1]
            $repoName = $Matches[2]
            $secretsUrl = "https://github.com/$owner/$repoName/settings/secrets/actions"
            Write-Ok "Репозиторий определён через git remote: $owner/$repoName"

            # Открываем страницу в браузере по умолчанию.
            try {
                Start-Process $secretsUrl
                Write-Ok "Страница secrets открыта в браузере"
            } catch {
                # Если браузер не открылся — не критично, ссылка ниже.
            }
        }
    } catch { }

    Write-Host ""
    Write-Host "Открой в браузере страницу secrets своего репозитория:"
    Write-Host "  $secretsUrl" -ForegroundColor White
    Write-Host ""
    Write-Host "Добавь четыре secret через кнопку 'New repository secret':"
    Write-Host ""
    Write-Host "  Name:  ANDROID_KEYSTORE_BASE64" -ForegroundColor White
    Write-Host "  Value: <вставь из буфера обмена>"
    Write-Host ""
    Write-Host "  Name:  ANDROID_KEYSTORE_PASSWORD" -ForegroundColor White
    Write-Host "  Value: <твой пароль>"
    Write-Host ""
    Write-Host "  Name:  ANDROID_KEY_ALIAS" -ForegroundColor White
    Write-Host "  Value: $Alias"
    Write-Host ""
    Write-Host "  Name:  ANDROID_KEY_PASSWORD" -ForegroundColor White
    Write-Host "  Value: <тот же пароль>"
    Write-Host ""
    Write-Warn "После загрузки base64 в UI — очисти буфер обмена (скопируй что-то другое)"
    Write-Warn "Также можно установить gh: winget install GitHub.cli; gh auth login"
    Write-Warn "и перезапустить этот скрипт — он загрузит secrets автоматически"
}

# --- Финальные подсказки ----------------------------------------------------

Write-Step "Дальнейшие шаги"
Write-Host "1. Сделай ОФФЛАЙН-бэкап файла:" -ForegroundColor White
Write-Host "      $KeystorePath" -ForegroundColor Gray
Write-Host "   Скопируй его на USB-флешку или в зашифрованный архив."
Write-Host "   Запиши пароль в надёжное место (менеджер паролей)."
Write-Host "   Потеря keystore = больше нельзя выпускать обновления." -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Выпусти тестовый релиз для проверки signing:" -ForegroundColor White
Write-Host "      git tag v1.1.1-signing-test" -ForegroundColor Gray
Write-Host "      git push origin v1.1.1-signing-test" -ForegroundColor Gray
Write-Host "   Через 5 минут зайди в Actions → Release → проверь, что в логе шаг"
Write-Host "   'Probe signing config' показывает 'Production signing: enabled'."
Write-Host ""
Write-Host "3. Установи новый APK поверх старого. Если успешно — production-signing работает." -ForegroundColor White

# Не оставляем пароль в памяти процесса дольше нужного.
$password = $null
[GC]::Collect()
