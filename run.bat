@echo off
java --add-exports java.desktop/com.sun.java.swing.plaf.windows=ALL-UNNAMED -Xms1024m -Xmx4096m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication -jar dist\SIMRSKhanza.jar
pause
