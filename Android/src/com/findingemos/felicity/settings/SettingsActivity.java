package com.findingemos.felicity.settings;

import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.Toast;

import com.findingemos.felicity.R;
import com.findingemos.felicity.backend.EmotionDatabase;
import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.emoticon.EmotionActivity;
import com.findingemos.felicity.twitter.Constants;
import com.findingemos.felicity.twitter.TwitterWebviewActivity;
import com.findingemos.felicity.visualization.VisualizationActivity;

public class SettingsActivity extends Activity {

	private int TWITTER_AUTH;
	private Twitter mTwitter;
	private RequestToken mRequestToken;

	private String accessToken;
	private String accessTokenSecret;

	private boolean haveConnectedWifi;
	private boolean haveConnectedMobile;

	private boolean twitterEnabled;
	private boolean firstnameFirst;
	
	// moet een veld zijn om terug te kunnen annuleren als webview faalt.
	private CheckBox enableTwitter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);

		SharedPreferences settings = PreferenceManager
				.getDefaultSharedPreferences(this);
		accessToken = settings.getString("twitter_access_token", null);
		accessTokenSecret = settings.getString("twitter_access_token_secret",
				null);
		twitterEnabled = settings.getBoolean("twitter enabled", false);
		firstnameFirst = settings.getBoolean("firstname enabled", true);

		setTitle("Settings");

		final EmotionDatabase database = EmotionActivity.DATABASE;
		// firstName = database.firstNameFirst();

		Button clearDatabase = (Button) findViewById(R.id.clearDatabaseButton);
		clearDatabase.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				DialogInterface.OnClickListener dialogClickListener = new DialogInterface.OnClickListener() {
					@Override
					public void onClick(DialogInterface dialog, int which) {
						switch (which) {
						case DialogInterface.BUTTON_POSITIVE:
							database.emty();
							database.readEmotionCount();
							database.readEmotionDatabase();

							for (Emotion e : Emotion.values()) {
								e.setSelectionCount(0);
							}

							Intent intent = new Intent(getApplicationContext(),
									EmotionActivity.class);
							startActivity(intent);

							CharSequence text = "Database cleared!";
							VisualizationActivity.resetFiler();
							int duration = Toast.LENGTH_SHORT;
							Toast toast = Toast.makeText(
									getApplicationContext(), text, duration);
							toast.show();
							finish();
							break;

						case DialogInterface.BUTTON_NEGATIVE:
							// No button clicked
							break;
						}
					}
				};

				AlertDialog.Builder builder = new AlertDialog.Builder(
						SettingsActivity.this);
				builder.setMessage(
						"Are you sure, this will delete ALL data in Felicity?")
						.setPositiveButton("Yes", dialogClickListener)
						.setNegativeButton("No", dialogClickListener).show();

			}
		});

		CheckBox firstname = (CheckBox) findViewById(R.id.firstNameFirstButton);
		firstname.setChecked(firstnameFirst);
		firstname.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				firstnameFirst = !firstnameFirst;
				SharedPreferences settings = PreferenceManager
						.getDefaultSharedPreferences(SettingsActivity.this);
				SharedPreferences.Editor editor = settings.edit();
				editor.putBoolean("firstname enabled", firstnameFirst);
				editor.commit();
				// database.changeFirstNameFirst(SettingsActivity.firstName);

			}
		});

		enableTwitter = (CheckBox) findViewById(R.id.enableTwitterButton);
		enableTwitter.setChecked(twitterEnabled);
		enableTwitter.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				twitterEnabled = !twitterEnabled;
				SharedPreferences settings = PreferenceManager
						.getDefaultSharedPreferences(SettingsActivity.this);

				accessToken = settings.getString("twitter_access_token", null);
				accessTokenSecret = settings.getString(
						"twitter_access_token_secret", null);

				SharedPreferences.Editor editor = settings.edit();
				editor.putBoolean("twitter enabled", twitterEnabled);
				editor.commit();
				
				if ((accessToken != null) && (accessTokenSecret != null)) {
					return;
				}

				// new Thread(new Runnable() {
				// public void run() {
				haveNetworkConnection();
				if ((haveConnectedWifi) || (haveConnectedMobile)) {

					if ((accessToken == null) || (accessTokenSecret == null)) {
						mTwitter = new TwitterFactory().getInstance();
						mRequestToken = null;
						mTwitter.setOAuthConsumer(Constants.CONSUMER_KEY,
								Constants.CONSUMER_SECRET);
						String callbackURL = getResources().getString(
								R.string.twitter_callback);
						try {
							mRequestToken = mTwitter
									.getOAuthRequestToken(callbackURL);
						} catch (TwitterException e) {
							e.printStackTrace();
						}
						Intent i = new Intent(SettingsActivity.this,
								TwitterWebviewActivity.class);
						i.putExtra("URL", mRequestToken.getAuthenticationURL());
						startActivityForResult(i, TWITTER_AUTH);
					} else {
						// Token was reeds gevonden
					}
				} else {
					Toast.makeText(SettingsActivity.this,
							"No access to Internet..please enable your internet first", Toast.LENGTH_LONG)
							.show();
					cancelTwitter(settings);
				}
			}

		});
	}
	
	/**
	 * @param settings
	 */
	private void cancelTwitter(SharedPreferences settings) {
		SharedPreferences.Editor editor = settings.edit();
		editor.putBoolean("twitter enabled", false);
		editor.commit();
		enableTwitter.setChecked(false);
		twitterEnabled = false;
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		SharedPreferences settings = PreferenceManager
				.getDefaultSharedPreferences(this);
		try {
			if (requestCode == TWITTER_AUTH) {

				if (resultCode == Activity.RESULT_OK) {
					String oauthVerifier = (String) data.getExtras().get(
							"oauth_verifier");

					AccessToken at = null;

					try {
						// Pair up our request with the response
						at = mTwitter.getOAuthAccessToken(oauthVerifier);
						String theToken = at.getToken();
						String theTokenSecret = at.getTokenSecret();
						settings = PreferenceManager
								.getDefaultSharedPreferences(this);
						SharedPreferences.Editor editor = settings.edit();
						editor.putString("twitter_access_token", theToken);
						editor.putString("twitter_access_token_secret",
								theTokenSecret);
						editor.commit();
					} catch (TwitterException e) {
						// De gebruiker heeft op cancel gedrukt in de webview
						Toast.makeText(SettingsActivity.this,"No access granted from Twitter", Toast.LENGTH_LONG).show();
						cancelTwitter(settings);
					}
				}
			} else {
				Log.e("SettinsActivity","Twitterpage came back with wrong results");
			}
		} catch (Exception e) {
			// De gebruiker heeft op cancel gedrukt in de webview
			Toast.makeText(SettingsActivity.this,"No access granted from Twitter", Toast.LENGTH_LONG).show();
			cancelTwitter(settings);
			
		}

	}
	
	private boolean haveNetworkConnection() {
		haveConnectedWifi = false;
		haveConnectedMobile = false;

		ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo[] netInfo = cm.getAllNetworkInfo();
		for (NetworkInfo ni : netInfo) {
			if (ni.getTypeName().equalsIgnoreCase("WIFI"))
				if (ni.isConnected())
					haveConnectedWifi = true;
			if (ni.getTypeName().equalsIgnoreCase("MOBILE"))
				if (ni.isConnected())
					haveConnectedMobile = true;
		}
		return haveConnectedWifi || haveConnectedMobile;
	}

}
