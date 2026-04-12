#!/system/bin/sh
MDIR=/vendor/etc/gpu_ko
LOG=/mnt/vendor/persist/gpu_load.log
echo "Starting GPU module load" > $LOG

MODS="mtk-mbox.ko mtk_rpmsg_mbox.ko mtk_tinysys_ipi.ko sspm.ko mtk_pbm.ko mtk_low_battery_throttling.ko mtk_battery_oc_throttling.ko mtk_dynamic_loading_throttling.ko mtk_md_power_throttling.ko mtk_mdpm_v1.ko mtk_cpu_power_throttling.ko mtk_peak_power_budget.ko mtk_qos.ko mtk_cm_mgr.ko mtk_cm_mgr_mt6877.ko mtk_gpufreq_wrapper_legacy.ko mtk_gpufreq_mt6877.ko mtk_gpu_hal.ko mtk_gpu_qos.ko ged.ko mali_prot_alloc_mt6877_r49.ko mali_mgm_mt6877_r49.ko mali_kbase_mt6877_r49.ko mdp_drv_mt6877.ko"

# Pass 1
echo "=== Pass 1 ===" >> $LOG
for mod in $MODS; do
    [ -f "$MDIR/$mod" ] && insmod "$MDIR/$mod" 2>/dev/null
done

# Pass 2 - retry failed ones
echo "=== Pass 2 ===" >> $LOG
for mod in $MODS; do
    [ -f "$MDIR/$mod" ] && insmod "$MDIR/$mod" 2>/dev/null
done

# Pass 3 - final retry
echo "=== Pass 3 ===" >> $LOG
for mod in $MODS; do
    [ -f "$MDIR/$mod" ] && insmod "$MDIR/$mod" 2>>$LOG
    echo "$mod: $?" >> $LOG
done

echo "Done" >> $LOG

# Fix Mali GPU permissions after module load (race condition with ueventd)
sleep 0.5
chmod 0666 /dev/mali0 2>/dev/null
chmod 0666 /dev/mali 2>/dev/null
