package com.rainx.usbaudiosettings;

import android.app.Activity;
import android.os.Bundle;
import android.os.SystemProperties;
import android.provider.Settings;
import android.util.TypedValue;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class UsbAudioSettingsActivity extends Activity {

    private static final String MODE_FILE = "/data/local/tmp/.usb_speaker_mode";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        int pad = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, 24, getResources().getDisplayMetrics());
        layout.setPadding(pad, pad, pad, pad);

        TextView title = new TextView(this);
        title.setText("USB Speaker Mode");
        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
        layout.addView(title);

        TextView summary = new TextView(this);
        summary.setText("Enable to let your PC play audio through this speaker via USB.\nRequires USB cable reconnection after toggling.");
        summary.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        summary.setPadding(0, 8, 0, 24);
        layout.addView(summary);

        Switch toggle = new Switch(this);
        toggle.setText("Enable USB Speaker");
        toggle.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);

        toggle.setChecked(new File(MODE_FILE).exists());

        toggle.setOnCheckedChangeListener((v, checked) -> {
            try {
                if (checked) {
                    new FileWriter(MODE_FILE).close();
                } else {
                    new File(MODE_FILE).delete();
                }
            } catch (IOException ignored) {}
        });

        layout.addView(toggle);
        setContentView(layout);
    }
}
