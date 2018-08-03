package com.jzoom.flutterjpush;

import android.util.Log;

import cn.jpush.android.service.JPushMessageReceiver;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.Map;
import java.util.List;
import java.util.Set;
import java.util.ArrayList;
import java.util.HashMap;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Notification;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.SparseArray;

import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedHashSet;

import cn.jpush.android.api.BasicPushNotificationBuilder;
import cn.jpush.android.api.CustomPushNotificationBuilder;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.api.JPushMessage;
import cn.jpush.android.data.JPushLocalNotification;

/**
 * FlutterJPushPlugin
 */
public class FlutterJPushPlugin implements MethodCallHandler {


    private MethodChannel channel;
    private Activity activity;

    public FlutterJPushPlugin(MethodChannel channel, Activity activity) {
        sCacheMap = new SparseArray<>();
        this.channel = channel;
        this.activity = activity;
        _me = this;
    }

    private static FlutterJPushPlugin _me;

    private static FlutterJPushPlugin me() {

        return _me;
    }

    private Activity getCurrentActivity() {
        return activity;
    }

    private Context getApplicationContext() {
        return activity == null ? null : activity.getApplicationContext();
    }


    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_jpush");
        Log.d(TAG, "register jpush plugin");

        channel.setMethodCallHandler(new FlutterJPushPlugin(
                channel, registrar.activity()
        ));

        FlutterJPushPlugin.mRAC = registrar.activity();
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        String method = call.method;
        if ("initPush".equals(method)) {
            this.initPush();
            result.success(true);
        }else if ("startup".equals(method)) {
            this.startup();
            result.success(true);
        } else if ("getInfo".equals(method)) {
            this.getInfo(result);
        } else if ("stopPush".equals(method)) {
            this.stopPush();
            result.success(true);
        } else if ("resumePush".equals(method)) {
            this.resumePush();
            result.success(true);
        } else if ("crashLogOFF".equals(method)) {
            this.crashLogOFF();
            result.success(true);
        } else if ("crashLogON".equals(method)) {
            this.crashLogON();
            result.success(true);
        } else if ("setTags".equals(method)) {
            this.setTags((List) call.arguments, result);
        } else if ("addTags".equals(method)) {
            this.addTags((List) call.arguments, result);
        } else if ("deleteTags".equals(method)) {
            this.deleteTags((List) call.arguments, result);
        } else if ("cleanTags".equals(method)) {
            this.cleanTags(result);
        } else if ("getAllTags".equals(method)) {
            this.getAllTags(result);
        } else if ("checkTagBindState".equals(method)) {
            this.checkTagBindState((String) call.arguments, result);
        } else if ("setAlias".equals(method)) {
            this.setAlias((String) call.arguments, result);
        } else if ("deleteAlias".equals(method)) {
            this.deleteAlias(result);
        } else if ("getAlias".equals(method)) {
            this.getAlias(result);
        } else if ("setStyleBasic".equals(method)) {
            this.setStyleBasic();
            result.success(true);
        } else if ("setStyleCustom".equals(method)) {
            this.setStyleCustom();
            result.success(true);
        } else if ("getRegistrationID".equals(method)) {
            this.getRegistrationID(result);
        } else if ("getConnectionState".equals(method)) {
            this.getConnectionState(result);
        } else if ("clearAllNotifications".equals(method)) {
            this.clearAllNotifications();
            result.success(true);
        } else if ("clearNotificationById".equals(method)) {
            this.clearNotificationById((Integer) call.arguments);
            result.success(true);
        } else if ("setLatestNotificationNumber".equals(method)) {
            this.setLatestNotificationNumber((Integer) call.arguments);
            result.success(true);
        } else if ("setPushTime".equals(method)) {
            this.setPushTime((Map) call.arguments);
            result.success(true);
        } else if ("setSilenceTime".equals(method)) {
            this.setSilenceTime((Map) call.arguments);
            result.success(true);
        } else if ("sendLocalNotification".equals(method)) {
            this.sendLocalNotification((Map) call.arguments);
            result.success(true);
        } else if ("jumpToPushActivity".equals(method)) {
            this.jumpToPushActivity((String) call.arguments);
            result.success(true);
        } else if ("jumpToPushActivityWithParams".equals(method)) {
            Map map = (Map) call.arguments;
            this.jumpToPushActivityWithParams((String) map.get("activityName"), (Map) map.get("map"));
            result.success(true);
        } else if ("finishActivity".equals(method)) {
            this.finishActivity();
            result.success(true);
        } else if ("dispose".equals(method)) {
            this.dispose();
            result.success(true);
        } else {
            result.notImplemented();
        }
    }


    private static String TAG = "FlutterJPushPlugin";
    private Context mContext;
    private static String mEvent;
    private static Bundle mCachedBundle;
    private static Activity mRAC;

    private final static String RECEIVE_NOTIFICATION = "receiveNotification";
    private final static String RECEIVE_CUSTOM_MESSAGE = "receivePushMsg";
    private final static String OPEN_NOTIFICATION = "openNotification";
    private final static String RECEIVE_REGISTRATION_ID = "getRegistrationId";
    private final static String CONNECTION_CHANGE = "connectionChange";

    private static SparseArray<Result> sCacheMap;
    private static Result mGetRidResult;


    public void dispose() {
        mCachedBundle = null;
        if (null != sCacheMap) {
            sCacheMap.clear();
        }
        mEvent = null;
        mGetRidResult = null;
    }


    public void initPush() {

    }

    public void startup() {
        mContext = getCurrentActivity();
        JPushInterface.init(getApplicationContext());
        Logger.i(TAG, "init Success!");
    }


    public void getInfo(Result successResult) {
        Map map = new HashMap();
        String appKey = "AppKey:" + ExampleUtil.getAppKey(getApplicationContext());
        map.put("myAppKey", appKey);
        String imei = "IMEI: " + ExampleUtil.getImei(getApplicationContext(), "");
        map.put("myImei", imei);
        String packageName = "PackageName: " + getApplicationContext().getPackageName();
        map.put("myPackageName", packageName);
        String deviceId = "DeviceId: " + ExampleUtil.getDeviceId(getApplicationContext());
        map.put("myDeviceId", deviceId);
        String version = "Version: " + ExampleUtil.GetVersion(getApplicationContext());
        map.put("myVersion", version);
        successResult.success(map);
    }


    public void stopPush() {
        mContext = getCurrentActivity();
        JPushInterface.stopPush(getApplicationContext());
        Logger.i(TAG, "Stop push");
        Logger.toast(mContext, "Stop push success");
    }


    public void resumePush() {
        mContext = getCurrentActivity();
        JPushInterface.resumePush(getApplicationContext());
        Logger.i(TAG, "Resume push");
        Logger.toast(mContext, "Resume push success");
    }


    public void crashLogOFF() {
        JPushInterface.stopCrashHandler(getApplicationContext());
    }


    public void crashLogON() {
        JPushInterface.initCrashHandler(getApplicationContext());
    }


    void sendEvent() {
        if (mEvent != null) {
            Logger.i(TAG, "Sending event : " + mEvent);
            switch (mEvent) {
                case RECEIVE_CUSTOM_MESSAGE:
                    Map map = new HashMap();
                    map.put("id", (Integer) mCachedBundle.get(JPushInterface.EXTRA_NOTIFICATION_ID));
                    map.put("message", (String) mCachedBundle.get(JPushInterface.EXTRA_MESSAGE));
                    map.put("title",(String)mCachedBundle.get(JPushInterface.EXTRA_TITLE));
                    map.put("contentType",(String)mCachedBundle.get(JPushInterface.EXTRA_CONTENT_TYPE));
                    map.put("extras", (String) mCachedBundle.get(JPushInterface.EXTRA_EXTRA));
                    channel.invokeMethod("receivePushMsg", map);
                    break;
                case RECEIVE_REGISTRATION_ID:
                    if (mGetRidResult != null) {
                        mGetRidResult.success((String) mCachedBundle.get(JPushInterface.EXTRA_REGISTRATION_ID));
                        mGetRidResult = null;
                    }
                    channel.invokeMethod("networkDidLogin", (String) mCachedBundle.get(JPushInterface.EXTRA_REGISTRATION_ID));
                    break;
                case RECEIVE_NOTIFICATION:
                case OPEN_NOTIFICATION:
                    map = new HashMap();
                    map.put("id", (Integer) mCachedBundle.get(JPushInterface.EXTRA_NOTIFICATION_ID));
                    map.put("alertContent", (String) mCachedBundle.get(JPushInterface.EXTRA_ALERT));
                    map.put("extras", (String) mCachedBundle.get(JPushInterface.EXTRA_EXTRA));
                    map.put("title", mCachedBundle.get(JPushInterface.EXTRA_NOTIFICATION_TITLE));
                    map.put("alerType", (String) mCachedBundle.get(JPushInterface.EXTRA_ALERT_TYPE));
                    channel.invokeMethod(mEvent == OPEN_NOTIFICATION ? "openNotification" : "receiveNotification", map);
                    break;
                case CONNECTION_CHANGE:
                    if (mCachedBundle != null) {
                        channel.invokeMethod("connectionChange", mCachedBundle.getBoolean(JPushInterface.EXTRA_CONNECTION_CHANGE, false));
                    }
                    break;
            }
            mEvent = null;
            mCachedBundle = null;
        }
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Set tags
     *
     * @param tags   tags array
     * @param result result
     */

    public void setTags(final List tags, final Result result) {
        int sequence = getSequence();
        Logger.i(TAG, "sequence: " + sequence);
        sCacheMap.put(sequence, result);
        Logger.i(TAG, "tag: " + tags.toString());
        Set<String> tagSet = getSet(tags);
        JPushInterface.setTags(getApplicationContext(), sequence, tagSet);
    }

    private int getSequence() {
        SimpleDateFormat sdf = new SimpleDateFormat("MMddHHmmss");
        String date = sdf.format(new Date());
        return Integer.valueOf(date);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     *
     * @param tags   tags to be added
     * @param result result
     */

    public void addTags(List tags, Result result) {
        int sequence = getSequence();
        Logger.i(TAG, "tags to be added: " + tags.toString() + " sequence: " + sequence);
        sCacheMap.put(sequence, result);
        Set<String> tagSet = getSet(tags);
        JPushInterface.addTags(getApplicationContext(), sequence, tagSet);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     *
     * @param tags   tags to be deleted
     * @param result result
     */

    public void deleteTags(List tags, Result result) {
        int sequence = getSequence();
        Logger.i(TAG, "tags to be deleted: " + tags.toString() + " sequence: " + sequence);
        sCacheMap.put(sequence, result);
        Set<String> tagSet = getSet(tags);
        JPushInterface.deleteTags(getApplicationContext(), sequence, tagSet);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Clean all tags
     *
     * @param result result
     */

    public void cleanTags(Result result) {
        int sequence = getSequence();
        sCacheMap.put(sequence, result);
        Logger.i(TAG, "Will clean all tags, sequence: " + sequence);
        JPushInterface.cleanTags(getApplicationContext(), sequence);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Get all tags
     *
     * @param result result
     */

    public void getAllTags(Result result) {
        int sequence = getSequence();
        sCacheMap.put(sequence, result);
        Logger.i(TAG, "Get all tags, sequence: " + sequence);
        JPushInterface.getAllTags(getApplicationContext(), sequence);
    }

    private Set<String> getSet(List strArray) {
        Set<String> tagSet = new LinkedHashSet<>();
        for (int i = 0; i < strArray.size(); i++) {
            if (!ExampleUtil.isValidTagAndAlias((String) strArray.get(i))) {
                Logger.toast(getApplicationContext(), "Invalid tag !");
            }
            tagSet.add((String) strArray.get(i));
        }
        return tagSet;
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Check tag bind state
     *
     * @param tag    Tag to be checked
     * @param result result
     */

    public void checkTagBindState(String tag, Result result) {
        int sequence = getSequence();
        sCacheMap.put(sequence, result);
        Logger.i(TAG, "Checking tag bind state, tag: " + tag + " sequence: " + sequence);
        JPushInterface.checkTagBindState(getApplicationContext(), sequence, tag);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Set alias
     *
     * @param alias alias to be set
     */

    public void setAlias(String alias, Result result) {
        int sequence = getSequence();
        Logger.i(TAG, "Set alias, sequence: " + sequence);
        sCacheMap.put(sequence, result);
        JPushInterface.setAlias(getApplicationContext(), sequence, alias);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Delete alias
     *
     * @param result result
     */

    public void deleteAlias(Result result) {
        int sequence = getSequence();
        Logger.i(TAG, "Delete alias, sequence: " + sequence);
        sCacheMap.put(sequence, result);
        JPushInterface.deleteAlias(getApplicationContext(), sequence);
    }

    /**
     * JPush v3.0.7 Add this API
     * See document https://docs.jiguang.cn/jpush/client/Android/android_api/#aliastag for detail
     * Get alias
     *
     * @param result result
     */

    public void getAlias(Result result) {
        int sequence = getSequence();
        Logger.i(TAG, "Get alias, sequence: " + sequence);
        sCacheMap.put(sequence, result);
        JPushInterface.getAlias(getApplicationContext(), sequence);
    }


    /**
     * 设置通知提示方式 - 基础属性
     */

    public void setStyleBasic() {
        mContext = getCurrentActivity();
        if (mContext != null) {
            BasicPushNotificationBuilder builder = new BasicPushNotificationBuilder(mContext);
            builder.statusBarDrawable = IdHelper.getDrawable(mContext, "ic_launcher");
            builder.notificationFlags = Notification.FLAG_AUTO_CANCEL;  //设置为点击后自动消失
            builder.notificationDefaults = Notification.DEFAULT_SOUND;  //设置为铃声（ Notification.DEFAULT_SOUND）或者震动（ Notification.DEFAULT_VIBRATE）
            JPushInterface.setPushNotificationBuilder(1, builder);
            Logger.toast(mContext, "Basic Builder - 1");
        } else {
            Logger.d(TAG, "Current activity is null, discard event");
        }
    }

    /**
     * 设置通知栏样式 - 定义通知栏Layout
     */

    public void setStyleCustom() {
        mContext = getCurrentActivity();
        CustomPushNotificationBuilder builder = new CustomPushNotificationBuilder(mContext
                , IdHelper.getLayout(mContext, "customer_notification_layout"),
                IdHelper.getViewID(mContext, "icon"), IdHelper.getViewID(mContext, "title"),
                IdHelper.getViewID(mContext, "text"));
        builder.layoutIconDrawable = IdHelper.getDrawable(mContext, "ic_launcher");
        builder.developerArg0 = "developerArg2";
        JPushInterface.setPushNotificationBuilder(2, builder);
        Logger.toast(mContext, "Custom Builder - 2");
    }

    /**
     * Get registration id, different from FlutterJPushPlugin.addGetRegistrationIdListener, this
     * method has no calling limits.
     *
     * @param result result with registrationId
     */

    public void getRegistrationID(Result result) {
        try {
            String id = JPushInterface.getRegistrationID(getApplicationContext());
            if (id != null) {
                result.success(id);
            } else {
                mGetRidResult = result;
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    public void getConnectionState(Result result) {
        result.success(JPushInterface.getConnectionState(getApplicationContext()));
    }

    /**
     * Clear all notifications, suggest invoke this method while exiting app.
     */

    public void clearAllNotifications() {
        JPushInterface.clearAllNotifications(getApplicationContext());
    }

    /**
     * Clear specified notification
     *
     * @param id the notification id
     */

    public void clearNotificationById(int id) {
        try {
            mContext = getCurrentActivity();
            JPushInterface.clearNotificationById(mContext, id);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    public void setLatestNotificationNumber(int number) {
        try {
            mContext = getCurrentActivity();
            JPushInterface.setLatestNotificationNumber(mContext, number);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    public void setPushTime(Map map) {
        try {
            mContext = getCurrentActivity();
            List array = (List) map.get("days");
            Set<Integer> days = new HashSet<Integer>();
            for (int i = 0; i < array.size(); i++) {
                days.add((Integer) array.get(i));
            }
            int startHour = (Integer) map.get("startHour");
            int endHour = (Integer) map.get("endHour");
            JPushInterface.setPushTime(mContext, days, startHour, endHour);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    /**
     * Set silent push time
     *
     * @param map must includes startTime and endTime property
     */

    public void setSilenceTime(Map map) {
        try {
            mContext = getCurrentActivity();
            String starTime = (String) map.get("startTime");
            String endTime = (String) map.get("endTime");
            String[] sTime = starTime.split(":");
            String[] eTime = endTime.split(":");
            JPushInterface.setSilenceTime(mContext, Integer.valueOf(sTime[0]), Integer.valueOf(sTime[1]),
                    Integer.valueOf(eTime[0]), Integer.valueOf(eTime[1]));
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    public void sendLocalNotification(Map map) {
        try {
            JPushLocalNotification ln = new JPushLocalNotification();
            ln.setBuilderId((Integer) map.get("buildId"));
            ln.setNotificationId((Integer) map.get("id"));
            ln.setTitle((String) map.get("title"));
            ln.setContent((String) map.get("content"));
            Map extra = (Map) map.get("extra");
            JSONObject json = new JSONObject();
            map2intent(map, json);
            ln.setExtras(json.toString());
            if (map.containsKey("fireTime")) {
                long date = (long) (double) (Double) map.get("fireTime");
                ln.setBroadcastTime(date);
            }
            JPushInterface.addLocalNotification(getApplicationContext(), ln);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    /**
     * 接收自定义消息,通知,通知点击事件等事件的广播
     * 文档链接:http://docs.jiguang.cn/client/android_api/
     */
    public static class JPushReceiver extends BroadcastReceiver {

        public JPushReceiver() {
            Log.d("JPushReceiver", "JPushReceiver");
        }

        @Override
        public void onReceive(Context context, Intent data) {
            mCachedBundle = data.getExtras();
            if (JPushInterface.ACTION_MESSAGE_RECEIVED.equals(data.getAction())) {
                try {
                    if(!Logger.SHUTDOWNLOG){
                        String message = data.getStringExtra(JPushInterface.EXTRA_MESSAGE);
                        Logger.i(TAG, "收到自定义消息: " + message);
                    }

                    mEvent = RECEIVE_CUSTOM_MESSAGE;
                    if (mRAC != null) {
                        FlutterJPushPlugin.me().sendEvent();
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            } else if (JPushInterface.ACTION_NOTIFICATION_RECEIVED.equals(data.getAction())) {
                try {
                    if(!Logger.SHUTDOWNLOG){
                        // 通知内容
                        String alertContent = (String) mCachedBundle.get(JPushInterface.EXTRA_ALERT);
                        // extra 字段的 json 字符串
                        String extras = (String) mCachedBundle.get(JPushInterface.EXTRA_EXTRA);
                        Logger.i(TAG, "收到推送下来的通知: " + alertContent);
                        Logger.i(TAG, "extras: " + extras);
                    }
                    mEvent = RECEIVE_NOTIFICATION;
                    if (mRAC != null) {
                        FlutterJPushPlugin.me().sendEvent();
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            } else if (JPushInterface.ACTION_NOTIFICATION_OPENED.equals(data.getAction())) {
                try {
                    Logger.d(TAG, "用户点击打开了通知");
                    // 通知内容
                    String alertContent = (String) mCachedBundle.get(JPushInterface.EXTRA_ALERT);
                    // extra 字段的 json 字符串
                    String extras = (String) mCachedBundle.get(JPushInterface.EXTRA_EXTRA);
                    Intent intent;
                    if (isApplicationRunningBackground(context)) {
                        intent = new Intent();
                        intent.setClassName(context.getPackageName(), context.getPackageName() + ".MainActivity");
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    } else {
                        intent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
                        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP | Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    }
                    intent.putExtras(mCachedBundle);
                    context.startActivity(intent);
                    mEvent = OPEN_NOTIFICATION;
                    if (mRAC != null) {
                        FlutterJPushPlugin.me().sendEvent();
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                    Logger.i(TAG, "Shouldn't access here");
                }
                // 应用注册完成后会发送广播，在 JS 中 FlutterJPushPlugin.addGetRegistrationIdListener 接口可以第一时间得到 registrationId
                // After JPush finished registering, will send this broadcast, use FlutterJPushPlugin.addGetRegistrationIdListener
                // to get registrationId in the first instance.
            } else if (JPushInterface.ACTION_REGISTRATION_ID.equals(data.getAction())) {
                try {
                    mEvent = RECEIVE_REGISTRATION_ID;
                    if (mRAC != null) {
                        FlutterJPushPlugin.me().sendEvent();
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            } else if (JPushInterface.ACTION_CONNECTION_CHANGE.equals(data.getAction())) {
                try {
                    mEvent = CONNECTION_CHANGE;
                    if (mRAC != null) {
                        FlutterJPushPlugin.me().sendEvent();
                    }
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            }
        }

    }


    public static class MyJPushMessageReceiver extends JPushMessageReceiver {

        public MyJPushMessageReceiver() {
            Log.d(TAG, "MyJPushMessageReceiver init");
        }

        @Override
        public void onTagOperatorResult(Context context, JPushMessage jPushMessage) {
            String log = "action - onTagOperatorResult, sequence:" + jPushMessage.getSequence()
                    + ", tags: " + jPushMessage.getTags();
            Logger.i(TAG, log);
            Logger.toast(context, log);
            Logger.i(TAG, "tags size:" + jPushMessage.getTags().size());
            Result result = sCacheMap.get(jPushMessage.getSequence());
            if (null != result) {
                Map map = new HashMap();
                List<String> array = new ArrayList<String>();
                Set<String> tags = jPushMessage.getTags();
                for (String str : tags) {
                    array.add(str);
                }
                map.put("tags", array);
                map.put("errorCode", jPushMessage.getErrorCode());
                result.success(map);
                sCacheMap.remove(jPushMessage.getSequence());
            } else {
                Logger.i(TAG, "Unexpected error, null result!");
            }
            super.onTagOperatorResult(context, jPushMessage);
        }

        @Override
        public void onCheckTagOperatorResult(Context context, JPushMessage jPushMessage) {
            String log = "action - onCheckTagOperatorResult, sequence:" + jPushMessage.getSequence()
                    + ", checktag: " + jPushMessage.getCheckTag();
            Logger.i(TAG, log);
            Logger.toast(context, log);
            Result result = sCacheMap.get(jPushMessage.getSequence());
            if (null != result) {
                Map map = new HashMap();
                map.put("errorCode", jPushMessage.getErrorCode());
                map.put("tag", jPushMessage.getCheckTag());
                map.put("bindState", jPushMessage.getTagCheckStateResult());
                result.success(map);
                sCacheMap.remove(jPushMessage.getSequence());
            } else {
                Logger.i(TAG, "Unexpected error, null result!");
            }
            super.onCheckTagOperatorResult(context, jPushMessage);
        }

        @Override
        public void onAliasOperatorResult(Context context, JPushMessage jPushMessage) {
            String log = "action - onAliasOperatorResult, sequence:" + jPushMessage.getSequence()
                    + ", alias: " + jPushMessage.getAlias();
            Logger.i(TAG, log);
            Logger.toast(context, log);
            Result result = sCacheMap.get(jPushMessage.getSequence());
            if (null != result) {
                Map map = new HashMap();
                map.put("alias", jPushMessage.getAlias());
                map.put("errorCode", jPushMessage.getErrorCode());
                result.success(map);
                sCacheMap.remove(jPushMessage.getSequence());
            } else {
                Logger.i(TAG, "Unexpected error, null result!");
            }
            super.onAliasOperatorResult(context, jPushMessage);
        }
    }

    private static boolean isApplicationRunningBackground(final Context context) {
        ActivityManager am = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningTaskInfo> tasks = am.getRunningTasks(1);
        if (!tasks.isEmpty()) {
            ComponentName topActivity = tasks.get(0).topActivity;
            if (!topActivity.getPackageName().equals(context.getPackageName())) {
                return true;
            }
        }
        return false;
    }


    public void jumpToPushActivity(String activityName) {
        Logger.d(TAG, "Jumping to " + activityName);
        try {
            Intent intent = new Intent();
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setClassName(mRAC, mRAC.getPackageName() + "." + activityName);
            mRAC.startActivity(intent);

        } catch (Throwable e) {
            e.printStackTrace();
        }

    }


    public void jumpToPushActivityWithParams(String activityName, Map map) {
        Logger.d(TAG, "Jumping to " + activityName);
        try {
            Intent intent = new Intent();
            if (null != map) {
                map2intent(map, intent);
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.setClassName(mRAC, mRAC.getPackageName() + "." + activityName);
            mRAC.startActivity(intent);
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }

    private void map2intent(Map<String, Object> map, JSONObject intent) throws JSONException {
        for (java.util.Map.Entry<String, Object> entity : map.entrySet()) {
            intent.put(entity.getKey(), String.valueOf(entity.getValue()));
        }
    }

    private void map2intent(Map<String, Object> map, Intent intent) {
        for (java.util.Map.Entry<String, Object> entity : map.entrySet()) {
            intent.putExtra(entity.getKey(), String.valueOf(entity.getValue()));
        }
    }


    public void finishActivity() {
        try {
            Activity activity = getCurrentActivity();
            activity.finish();
        } catch (Throwable e) {
            e.printStackTrace();
        }

    }
}
