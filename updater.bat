@echo off
echo Menutup SIMRS Khanza...
timeout /t 3 /nobreak > NUL

echo Mendownload versi terbaru dari server...
:: Pastikan URL di bawah sesuai dengan folder tempat Anda menaruh file .jar baru di server
curl -o SIMRSKhanza.jar http://localhost/khanza-update/SIMRSKhanza.jar

echo Update selesai! Menjalankan ulang Khanza...
start javaw -jar SIMRSKhanza.jar
exit