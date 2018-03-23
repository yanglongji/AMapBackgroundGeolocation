var exec = require('cordova/exec');

var AMapBackgroundGeolocation = function() {};

AMapBackgroundGeolocation.start = function(suc,err) {
    exec(suc, err, "AMapBackgroundGeolocation", "start", []);
};
AMapBackgroundGeolocation.stop = function(suc,err) {
    exec(suc, err, "AMapBackgroundGeolocation", "stop", []);
};



module.exports = AMapBackgroundGeolocation;
