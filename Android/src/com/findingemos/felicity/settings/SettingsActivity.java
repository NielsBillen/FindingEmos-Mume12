package com.findingemos.felicity.settings;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.Toast;

import com.findingemos.felicity.R;
import com.findingemos.felicity.backend.EmotionDatabase;
import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.emoticon.EmotionActivity;

public class SettingsActivity extends Activity {

	static boolean firstName;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_settings);
		
		setTitle("Settings");

		final EmotionDatabase database = EmotionActivity.DATABASE;
		firstName = database.firstNameFirst();

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
		firstname.setChecked(firstName);
		firstname.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				SettingsActivity.firstName = !SettingsActivity.firstName;
				database.changeFirstNameFirst(SettingsActivity.firstName);

			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_settings, menu);
		return true;
	}

}
