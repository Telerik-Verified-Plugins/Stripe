package com.telerik.stripe;

import android.util.Base64;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class StripePlugin extends CordovaPlugin {

  private String baseUrl = "https://api.stripe.com/v1/";

  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    if (action.equals("process")) {
      try {
        this.processCommand(callbackContext, args);
      } catch (UnsupportedEncodingException e) {
        callbackContext.error(e.getMessage());
      }
      return true;
    }
    return false;
  }

  private void processCommand(final CallbackContext callbackContext, final JSONArray args) throws JSONException, UnsupportedEncodingException {

    int appResId = cordova.getActivity().getResources().getIdentifier("stripe_api_key", "string", cordova.getActivity().getPackageName());
    String apiKey = cordova.getActivity().getString(appResId);

    final HttpClient httpclient = new DefaultHttpClient();

    final String method = args.getString(0);
    String action = args.getString(1);

    String url = this.baseUrl + action;

    final HttpRequestBase httpRequest;

    JSONObject jsonObject = args.isNull(2) ? null : args.getJSONObject(2);
    if (method.equals("POST")) {
      httpRequest = new HttpPost(url);
      try {
        if (jsonObject != null) {
          ((HttpPost) httpRequest).setEntity(this.buildBody(jsonObject));
        }
      } catch (Exception e) {
        e.printStackTrace();
      }
    } else if (method.equals("DELETE")) {
      url = formatURL(url, getQueryString(jsonObject));
      httpRequest = new HttpDelete(url);
    } else {
      url = formatURL(url, getQueryString(jsonObject));
      httpRequest = new HttpGet(url);
    }

    String base64EncodedCredentials = "Basic " + Base64.encodeToString(apiKey.getBytes(), Base64.NO_WRAP);

    httpRequest.setHeader("Authorization", base64EncodedCredentials);
    httpRequest.setHeader("Content-Type", "application/x-www-form-urlencoded");

    cordova.getThreadPool().execute(new Runnable() {
      @Override
      public void run() {
        try {

          HttpResponse res = httpclient.execute(httpRequest);
          HttpEntity httpEntity = res.getEntity();
          JSONObject response = new JSONObject(EntityUtils.toString(httpEntity));

          callbackContext.success(response);

        } catch (Exception e) {
          callbackContext.error(e.getMessage());
        }
      }
    });
  }

  private HttpEntity buildBody(JSONObject body) throws UnsupportedEncodingException, JSONException {
    List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

    normalizeToNameValues("", nameValuePairs, body);

    return new UrlEncodedFormEntity(nameValuePairs);
  }

  private HttpParams buildParams(JSONObject body) throws UnsupportedEncodingException, JSONException {
    List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();

    normalizeToNameValues("", nameValuePairs, body);

    HttpParams params = new BasicHttpParams();
    for (NameValuePair pair : nameValuePairs) {
      params.setParameter(pair.getName(), pair.getValue());
    }
    return params;
  }

  private static void normalizeToNameValues(String root, List<NameValuePair> nameValuePairs, JSONObject jsonObject) throws JSONException {

    if (jsonObject == null) {
      return;
    }

    @SuppressWarnings("unchecked")
    Iterator<String> iterator = jsonObject.keys();

    while (iterator.hasNext()) {
      String key = iterator.next();

      try {
        if (jsonObject.get(key) instanceof JSONObject) {
          normalizeToNameValues(key, nameValuePairs, jsonObject.getJSONObject(key));
        } else {
          if (!root.isEmpty()) {
            nameValuePairs.add(new BasicNameValuePair(root + "[" + key + "]", jsonObject.getString(key)));
          } else {
            nameValuePairs.add(new BasicNameValuePair(key, jsonObject.getString(key)));
          }
        }
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
  }

  private static String getQueryString(JSONObject jsonObject) throws JSONException {
    String query = "";
    List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>();
    normalizeToNameValues("", nameValuePairs, jsonObject);
    for (NameValuePair pair : nameValuePairs) {
      if (query.length() > 0) {
        query += "&";
      }
      query += pair.getName() + "=" + pair.getValue();
    }
    return query;
  }

  private static String formatURL(String url, String query) {
    if (query == null || query.length() == 0) {
      return url;
    } else {
      // In some cases, URL can already contain a question mark (eg, upcoming invoice lines)
      String separator = url.contains("?") ? "&" : "?";
      return String.format("%s%s%s", url, separator, query);
    }
  }

}
