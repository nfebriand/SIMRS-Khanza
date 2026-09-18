package fungsi;

import java.net.URL;
import java.util.Scanner;
import javax.swing.JOptionPane;
import fungsi.koneksiDB;

public class UpdateHelper {
    public static void cekUpdate() {
        try {
            String urlUpdate = koneksiDB.URLUPDATE();
            String versiLokal = koneksiDB.VERSIAPP();
            
            if (urlUpdate.equals("")) return;

            URL url = new URL(urlUpdate);
            Scanner scanner = new Scanner(url.openStream());
            
            if (scanner.hasNext()) {
                String versiServer = scanner.nextLine().trim();
                
                if (!versiLokal.equals(versiServer)) {
                    int opsi = JOptionPane.showConfirmDialog(null, 
                        "Versi terbaru SIMRS (" + versiServer + ") tersedia.\n" +
                        "Versi Anda saat ini: " + versiLokal + ".\n\n" +
                        "Apakah Anda ingin mengupdate sekarang?", 
                        "Update Tersedia", 
                        JOptionPane.YES_NO_OPTION, 
                        JOptionPane.INFORMATION_MESSAGE);
                        
                    if (opsi == JOptionPane.YES_OPTION) {
                        jalankanProsesUpdate();
                    }
                }
            }
            scanner.close();
        } catch (Exception e) {
            System.out.println("Gagal mengecek update: " + e.getMessage());
        }
    }

    private static void jalankanProsesUpdate() {
        try {
            Runtime.getRuntime().exec("cmd /c start updater.bat");
            System.exit(0);
        } catch (Exception e) {
            JOptionPane.showMessageDialog(null, "Gagal menjalankan updater!");
        }
    }    
}
