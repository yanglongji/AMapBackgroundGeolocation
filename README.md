# AMapBackgroundGeolocation

AMapBackgroundGeolocation.start
AMapBackgroundGeolocation.stop

修改android/cordova/lib/pluginHandler.js
在40行左右加上以下代码
else if (obj.src.endsWith('.aidl')) {
                        dest = path.join('app/src/main/aidl', obj.targetDir.substring(4), path.basename(obj.src));
                    }