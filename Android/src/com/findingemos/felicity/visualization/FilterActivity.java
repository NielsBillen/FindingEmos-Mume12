package com.findingemos.felicity.visualization;

import java.util.ArrayList;
import java.util.List;

import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.provider.ContactsContract;
import android.support.v4.app.FragmentActivity;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;

import com.findingemos.felicity.R;
import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.emoticon.EmotionActivity;

public class FilterActivity extends FragmentActivity {

	private String TIME;
	private String LOCATION;
	private String WHO;
	private String DOING;
	
	private String timeFilter;
	private String locationFilter;
	private String doingFilter;
	private String whoFilter;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.filter_activity);

		initializeStringResources();

		makeFilterButton();

		makeTimeSpinner();

		makeLocationSpinner();

		makeWhoSpinner();

		makeDoingSpinner();
	}

	/**
	 * 
	 */
	private void initializeStringResources() {
		TIME = getApplicationContext().getResources().getString(
				R.string.visualizations_time);
		LOCATION = getApplicationContext().getResources().getString(
				R.string.visualizations_location);
		WHO = getApplicationContext().getResources().getString(
				R.string.visualizations_who);
		DOING = getApplicationContext().getResources().getString(
				R.string.visualizations_doing);
	}

	/**
	 * 
	 */
	private void makeDoingSpinner() {
		ArrowButton leftDoing = (ArrowButton) findViewById(R.id.doingArrowLeft);
		leftDoing.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightDoing = (ArrowButton) findViewById(R.id.doingArrowRight);
		rightDoing.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner doingSpinner = (OptionSpinner) findViewById(R.id.doingSpinner);
		doingSpinner.setLeftButton(leftDoing);
		doingSpinner.setRightButton(rightDoing);
		doingSpinner.setOptions(EmotionActivity.DATABASE.readActivities());
		doingSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				if (name != DOING)
					doingFilter = name;
			}
		});
	}

	/**
	 * 
	 */
	private void makeWhoSpinner() {
		ArrowButton leftWho = (ArrowButton) findViewById(R.id.whoArrowLeft);
		leftWho.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightWho = (ArrowButton) findViewById(R.id.whoArrowRight);
		rightWho.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner whoSpinner = (OptionSpinner) findViewById(R.id.whoSpinner);
		whoSpinner.setLeftButton(leftWho);
		whoSpinner.setRightButton(rightWho);
		whoSpinner.setOptions(loadContactNames());
		whoSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				System.out.println("Option changed!!!!!!!");
				if (name != WHO) {
					System.out.println("NameFilter: " + name);
					whoFilter = name;
				}
			}
		});
	}

	/**
	 * 
	 */
	private void makeFilterButton() {
		Button filterButton = (Button) findViewById(R.id.filterButton);
		filterButton.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				List<VisualizationResult> results = EmotionActivity.DATABASE
						.readWithFilters(timeFilter, locationFilter,
								whoFilter, doingFilter,
								getApplicationContext());
				transformToSelectionCount(results);
				Intent intent = new Intent(getApplicationContext(),
						VisualizationActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
				if(timeFilter == null) timeFilter = TIME;
				if(locationFilter == null) locationFilter = LOCATION;
				if(whoFilter == null) whoFilter = WHO;
				if(doingFilter == null) doingFilter = DOING;
				intent.putExtra("Filter", timeFilter + " > " + locationFilter + " > " + whoFilter + " > " + doingFilter);
				
				startActivity(intent);
				
				
				finish();

			}
		});
	}

	/**
	 * 
	 */
	private void makeTimeSpinner() {
		ArrowButton leftTime = (ArrowButton) findViewById(R.id.timeArrowLeft);
		leftTime.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightTime = (ArrowButton) findViewById(R.id.timeArrowRight);
		rightTime.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner timeSpinner = (OptionSpinner) findViewById(R.id.timeSpinner);
		timeSpinner.setLeftButton(leftTime);
		timeSpinner.setRightButton(rightTime);
		timeSpinner.setOptions(TIME, "Today", "Week");
		timeSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				if (name != TIME)
					timeFilter = name;
			}
		});
	}

	/**
	 * 
	 */
	private void makeLocationSpinner() {
		ArrowButton leftLocation = (ArrowButton) findViewById(R.id.locationArrowLeft);
		leftLocation.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightLocation = (ArrowButton) findViewById(R.id.locationArrowRight);
		rightLocation.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner locationSpinner = (OptionSpinner) findViewById(R.id.locationSpinner);
		locationSpinner.setLeftButton(leftLocation);
		locationSpinner.setRightButton(rightLocation);
		String[] locationSpinnerOptions = makeLocationSpinnerOptions();
		locationSpinner.setOptions(locationSpinnerOptions);
		locationSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				if (name != LOCATION)
					locationFilter = name;
			}
		});
	}

	/**
	 * @return
	 */
	private String[] makeLocationSpinnerOptions() {
		String[] locations = EmotionActivity.DATABASE.readLocations();
		String[] locationSpinnerOptions = new String[locations.length + 1];
		locationSpinnerOptions[0] = LOCATION;
		int i = 1;
		for(String location : locations) {
			locationSpinnerOptions[i] = location;
			i++;
		}
		return locationSpinnerOptions;
	}

	protected void transformToSelectionCount(List<VisualizationResult> results) {

		int[] counts = new int[Emotion.values().length];
		for (VisualizationResult result : results) {
			int id = result.getEmotionId();
			int oldCount = counts[id];
			counts[id] = oldCount + 1;
		}

		Emotion[] resultSet = Emotion.values();
		for (Emotion emotion : resultSet) {
			emotion.setSelectionCount(counts[emotion.getUniqueId()]);
		}

		VisualizationActivity.setCurrentData(resultSet);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}

	private String[] loadContactNames() {
		Uri uri = ContactsContract.Contacts.CONTENT_URI;
		String[] projection = new String[] {
				ContactsContract.Contacts.DISPLAY_NAME, BaseColumns._ID,
				ContactsContract.Contacts.HAS_PHONE_NUMBER };
		Cursor people = getContentResolver().query(uri, projection, null, null,
				ContactsContract.Contacts.DISPLAY_NAME);

		int indexName = people
				.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME);
		int indexHasNumber = people
				.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER);

		List<String> contacts = new ArrayList<String>();
		contacts.add(WHO);
		while (people.moveToNext()) {
			String hasNumber = people.getString(indexHasNumber);
			if (hasNumber.equals("1")) {
				contacts.add(people.getString(indexName));
			}
		}

		String[] resultSet = new String[contacts.size()];
		int i = 0;
		for (String contact : contacts) {
			resultSet[i] = contact;
			i++;
		}

		return resultSet;
	}
}
