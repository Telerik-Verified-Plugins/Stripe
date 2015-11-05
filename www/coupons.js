var exec = require('cordova/exec');
var channel = require('cordova/channel');

function Coupons(){
  this.processRequest = function(args, cb, error){
      exec(cb,error, "Stripe", "process", args);
  };
}

Coupons.prototype.create = function(arg, successCallback, errorCallback){
    this.processRequest(["POST","coupons", arg], successCallback, errorCallback);
}

Coupons.prototype.retrieve = function(id, successCallback, errorCallback){
    this.processRequest(["GET","coupons/" + id, null], successCallback, errorCallback);
}

Coupons.prototype.update = function(id, arg, successCallback, errorCallback){
    this.processRequest(["POST","coupons/" + id, arg], successCallback, errorCallback);
}
Coupons.prototype.remove = function(successCallback, errorCallback){
  this.processRequest(["DELETE","coupons/", null], successCallback, errorCallback);
}
Coupons.prototype.list = function(successCallback, errorCallback){
  this.processRequest(["GET","coupons/", null], successCallback, errorCallback);
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = new Coupons();
}
