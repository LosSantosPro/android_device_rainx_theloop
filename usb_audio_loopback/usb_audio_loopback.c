/* USB UAC2 gadget capture -> primary speaker via tinyalsa. */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <tinyalsa/asoundlib.h>

#define LOG_TAG "usb_audio_loopback"
#include <log/log.h>

#define PLAYBACK_CARD    0
#define PLAYBACK_DEVICE  0
#define SAMPLE_RATE      48000
#define CHANNELS         2
#define PERIOD_SIZE      1024
#define PERIOD_COUNT     4
#define POLL_INTERVAL_US 500000

static int find_uac2_card(void) {
    FILE *f = fopen("/proc/asound/cards", "r");
    if (!f) return -1;

    char line[256];
    int card = -1;
    while (fgets(line, sizeof(line), f)) {
        int num;
        if (sscanf(line, " %d [", &num) == 1)
            card = num;
        if (strstr(line, "UAC2_Gadget") || strstr(line, "UAC2Gadget") ||
            strstr(line, "uac2") || strstr(line, "USB Gadget"))
            break;
        card = -1;
    }
    fclose(f);
    return card;
}

/* Find any non-primary ALSA card (UAC2 will be card >= 1). */
static int find_new_card(void) {
    int card = find_uac2_card();
    if (card > 0) return card;

    /* Fallback: look for any card other than 0 */
    FILE *f = fopen("/proc/asound/cards", "r");
    if (!f) return -1;

    char line[256];
    int last_card = -1;
    while (fgets(line, sizeof(line), f)) {
        int num;
        if (sscanf(line, " %d [", &num) == 1 && num > 0)
            last_card = num;
    }
    fclose(f);
    return last_card;
}

static void run_loopback(int capture_card) {
    struct pcm_config cap_cfg = {
        .channels = CHANNELS,
        .rate = SAMPLE_RATE,
        .period_size = PERIOD_SIZE,
        .period_count = PERIOD_COUNT,
        .format = PCM_FORMAT_S16_LE,
    };
    struct pcm_config play_cfg = cap_cfg;

    struct pcm *cap = pcm_open(capture_card, 0, PCM_IN, &cap_cfg);
    if (!cap || !pcm_is_ready(cap)) {
        ALOGE("Cannot open capture card %d: %s", capture_card,
              cap ? pcm_get_error(cap) : "null");
        if (cap) pcm_close(cap);
        return;
    }

    struct pcm *play = pcm_open(PLAYBACK_CARD, PLAYBACK_DEVICE, PCM_OUT, &play_cfg);
    if (!play || !pcm_is_ready(play)) {
        ALOGE("Cannot open playback card %d device %d: %s",
              PLAYBACK_CARD, PLAYBACK_DEVICE,
              play ? pcm_get_error(play) : "null");
        if (play) pcm_close(play);
        pcm_close(cap);
        return;
    }

    int frame_bytes = CHANNELS * 2; /* 16-bit stereo */
    int buf_bytes = PERIOD_SIZE * frame_bytes;
    char *buf = malloc(buf_bytes);
    if (!buf) {
        ALOGE("Failed to allocate buffer");
        pcm_close(play);
        pcm_close(cap);
        return;
    }

    ALOGI("Loopback started: card %d -> card %d device %d (%dHz %dch)",
          capture_card, PLAYBACK_CARD, PLAYBACK_DEVICE, SAMPLE_RATE, CHANNELS);

    while (1) {
        int ret = pcm_read(cap, buf, buf_bytes);
        if (ret != 0) {
            ALOGE("Capture read error: %s", pcm_get_error(cap));
            break;
        }
        ret = pcm_write(play, buf, buf_bytes);
        if (ret != 0) {
            ALOGE("Playback write error: %s", pcm_get_error(play));
            break;
        }
    }

    ALOGI("Loopback stopped");
    free(buf);
    pcm_close(play);
    pcm_close(cap);
}

int main(void) {
    ALOGI("USB audio loopback service starting");

    /* Wait for a UAC2 card to appear */
    int card = -1;
    for (int i = 0; i < 60; i++) { /* 30 second timeout */
        card = find_new_card();
        if (card > 0) break;
        usleep(POLL_INTERVAL_US);
    }

    if (card <= 0) {
        ALOGE("No UAC2 card found after timeout");
        return 1;
    }

    ALOGI("Found UAC2 card %d, starting loopback", card);
    run_loopback(card);
    return 0;
}
