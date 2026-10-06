@echo off
title Auto Update SIMRS Khanza
cd /d "%~dp0"

echo Menutup SIMRS Khanza...
taskkill /F /IM javaw.exe /FI "WINDOWTITLE eq SIMRS*" > NUL 2>&1
taskkill /F /IM java.exe > NUL 2>&1
timeout /t 2 /nobreak > NUL

echo Mendownload paket update (simrs.zip)...
curl -f -o simrs.zip http://10.10.20.44/simrs.zip

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Gagal mengunduh file simrs.zip dari server!
    echo Periksa koneksi jaringan.
    pause
    exit
)

echo Ekstrak dan timpa file lama...
tar -xf simrs.zip
del simrs.zip

echo.
echo Update selesai! Menjalankan ulang SIMRS Khanza...
@echo off
java -jar --add-exports java.desktop/com.sun.java.swing.plaf.windows=ALL-UNNAMED -jar  -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication SIMRSKhanza.jar
