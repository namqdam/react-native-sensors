package com.sensors;

import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.support.annotation.Nullable;
import android.util.Log;
import com.facebook.react.bridge.*;
import com.facebook.react.modules.core.DeviceEventManagerModule;

/**
 * Created by namdam on 09/06/2017.
 */
public class DeviceMotion extends ReactContextBaseJavaModule implements SensorEventListener {

    private final ReactApplicationContext reactContext;
    private final SensorManager sensorManager;
    private final Sensor sensor;
    private double lastReading = (double) System.currentTimeMillis();
    private int interval;
    private Arguments arguments;

    public DeviceMotion(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
        this.sensorManager = (SensorManager)reactContext.getSystemService(reactContext.SENSOR_SERVICE);
        this.sensor = this.sensorManager.getDefaultSensor(Sensor.TYPE_GRAVITY);
    }

    // RN Methods
    @ReactMethod
    public void setUpdateInterval(int newInterval) {
        this.interval = newInterval;
    }

    @ReactMethod
    public void startUpdates() {
        if (this.sensor == null) {
            // No sensor found, throw error
            throw new RuntimeException("No DeviceMotion found");
        }
        // Milisecond to Mikrosecond conversion
        sensorManager.registerListener(this, sensor, this.interval * 1000);
    }

    @ReactMethod
    public void stopUpdates() {
        sensorManager.unregisterListener(this);
    }

    @Override
    public String getName() {
        return "DeviceMotion";
    }

    // SensorEventListener Interface
    private void sendEvent(String eventName, @Nullable WritableMap params) {
        try {
            this.reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                    .emit(eventName, params);
        } catch (RuntimeException e) {
            Log.e("ERROR", "java.lang.RuntimeException: Trying to invoke Javascript before CatalystInstance has been set!");
        }
    }


    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        double tempMs = (double) System.currentTimeMillis();
        if (tempMs - lastReading >= interval){
            lastReading = tempMs;

            Sensor mySensor = sensorEvent.sensor;
            WritableMap map = arguments.createMap();
            if (mySensor.getType() == Sensor.TYPE_GRAVITY) {
                Double rotation = (180 / Math.PI) * Math.atan2(sensorEvent.values[0], sensorEvent.values[1]);
                map.putDouble("rotation", rotation);
                map.putDouble("timestamp", (double) System.currentTimeMillis());
                sendEvent("DeviceMotion", map);
            }
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
    }
}
