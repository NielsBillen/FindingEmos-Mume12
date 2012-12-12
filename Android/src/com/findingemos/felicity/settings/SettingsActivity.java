package com.findingemos.felicity.settings;

import android.app.Activity;
import android.os.Bundle;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.ToggleButton;

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
		
		final EmotionDatabase database = EmotionActivity.DATABASE;
		firstName = database.firstNameFirst();
		
		Button clearDatabase = (Button) findViewById(R.id.clearDatabaseButton);
		clearDatabase.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				database.emty();
				database.readEmotionCount();
				database.readEmotionDatabase();

				for (Emotion e : Emotion.values()) {
					e.setSelectionCount(0);
				}
				
			}
		});
		
		ToggleButton firstname = (ToggleButton) findViewById(R.id.firstNameFirstButton);
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
