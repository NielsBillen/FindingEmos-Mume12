package com.findingemos.felicity.doing;

import java.util.ArrayList;
import java.util.Arrays;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.findingemos.felicity.R;
import com.findingemos.felicity.backend.EmotionDatabase;
import com.findingemos.felicity.emoticon.EmotionActivity;
import com.findingemos.felicity.friends.FriendsActivity;

/**
 * Deze activiteit vraagt de gebruiker wat hij momenteel aan het doen is.
 * 
 * @author Stijn
 * 
 */
public class DoingActivity extends Activity {

	// Variable die de database bijhoudt.
	public static EmotionDatabase DATABASE = EmotionActivity.DATABASE;

	// Code voor het opvragen met welke vrienden de gebruiker is.
	private final static int FRIENDS_ACTIVITY_CODE = 1;

	// Variable die de huidige activiteit bijhoudt die de gebruiker aan het doen
	// is.
	private String currentActivity;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Log.i("Activity", "Doing started");
		setContentView(R.layout.doing_activity);
		setTitle("What are you doing?");

		initializeCategories();
		initializeAddButton();
	}

	@Override
	public void onBackPressed() {
		EmotionActivity.doingStarted = false;
		EmotionActivity.decrementSelectionCountOfCurrentEmotion();
		Intent intent = new Intent(getApplicationContext(),
				EmotionActivity.class);
		startActivity(intent);
		finish();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.Activity#onActivityResult(int, int,
	 * android.content.Intent)
	 */
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (resultCode != RESULT_OK) {
			System.out.println("Result from friends is not ok!");
			return;
		}

		if (requestCode == FRIENDS_ACTIVITY_CODE) {
			ArrayList<String> friends = new ArrayList<String>();

			if (data != null) {
				friends = data.getStringArrayListExtra("friends");
			}

			Intent result = new Intent();
			result.putExtra("activity", currentActivity);
			result.putExtra("friends", friends);
			setResult(RESULT_OK, result);
			finish();
		}
	}

	// ////////////////////////////////////////////////////
	// / Categorie‘n ///
	// ////////////////////////////////////////////////////

	/**
	 * Methode die de opgeslagen methodes uit de database ophaalt en ze
	 * weergeeft op het scherm.
	 */
	private void initializeCategories() {
		DATABASE.open();
		String[] activities = DATABASE.readActivities();

		for (int i = 0; i < activities.length; i++) {
			createCategoryButton(activities[i]);
		}
	}

	/**
	 * Methode die voor de meegegeven categorie een knop creeert op het scherm.
	 * 
	 * @param category
	 */
	private void createCategoryButton(String category) {
		Button newButton = new Button(this);
		newButton.setText(category);
		newButton.setTextColor(getBaseContext().getResources().getColor(
				R.color.White));
		newButton
				.setBackgroundResource(R.xml.doing_activity_button_background);
		newButton.setTextSize(18);

		LinearLayout ll = (LinearLayout) findViewById(R.id.doing_linearlayout);
		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
				android.view.ViewGroup.LayoutParams.MATCH_PARENT, 80);
		lp.setMargins(15, 15, 15, 0);
		ll.addView(newButton, lp);

		newButton.setOnClickListener(categoryButtonClickListener);
	}

	// Variable die de actie van de categorie-knoppen aangeeft.
	private OnClickListener categoryButtonClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			;
			Button button = (Button) v;
			currentActivity = (String) button.getText();

			DATABASE.open();
			DATABASE.updateActivityCount(currentActivity);
			Log.i("Count", "" + DATABASE.getCountOfActivity(currentActivity));

			Intent intent = new Intent(getApplicationContext(),
					FriendsActivity.class);
			startActivityForResult(intent, FRIENDS_ACTIVITY_CODE);
		}
	};

	// ////////////////////////////////////////////////////
	// / Add Button ///
	// ////////////////////////////////////////////////////

	/**
	 * Methode die de actie van Add-button initialiseert.
	 */
	private void initializeAddButton() {
		Button addButton = (Button) findViewById(R.id.doing_button_add);
		addButton.setOnClickListener(addButtonClickListener);
	}

	// Variable die de actie van de add-knop aangeeft.
	private OnClickListener addButtonClickListener = new OnClickListener() {

		@Override
		public void onClick(View v) {
			EditText et = (EditText) findViewById(R.id.doing_edittext_add_category);
			String newCategory = et.getText().toString();

			InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
			mgr.hideSoftInputFromWindow(et.getWindowToken(), 0);

			DATABASE.open();
			boolean categoryAlreadyExists = Arrays.asList(
					DATABASE.readActivities()).contains(newCategory);

			if (newCategory.equals("")) {
				Toast.makeText(getApplicationContext(),
						"Category can't be empty!", Toast.LENGTH_SHORT).show();
			} else if (categoryAlreadyExists) {
				Toast.makeText(getApplicationContext(),
						"Category already exists!", Toast.LENGTH_SHORT).show();
			} else {
				createCategoryButton(newCategory);
				et.setFocusableInTouchMode(false);
				et.setText("");
				et.setHint("Enter new category");

				DATABASE.open();
				DATABASE.createActivityEntry(newCategory);
			}
		}
	};

}
