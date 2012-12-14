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
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
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

	public final static String TODAY = "Today";
	public final static String WEEK = "This Week";
	public final static String MONTH = "This Month";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.filter_activity);
		
		setTitle("Adjust your filters!");

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
		String[] activities = EmotionActivity.DATABASE.readActivities();
		String[] doingOptions = new String[activities.length + 1];
		doingOptions[0] = DOING;
		int i = 1;
		for (String doing : activities) {
			doingOptions[i] = doing;
			i++;
		}
		Spinner spinner = new Spinner(this);
		ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<String>(
				this, android.R.layout.simple_spinner_item, doingOptions) {
			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				View v = super.getView(position, convertView, parent);

				((TextView) v).setTextSize(25);
				((TextView) v).setTextColor(getResources().getColorStateList(
						R.color.White));
				return v;
			}
		};
		spinnerArrayAdapter
				.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

		spinner = (Spinner) findViewById(R.id.doingSpinner);
		spinner.setAdapter(spinnerArrayAdapter);
		spinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int pos, long id) {
				String name = (String) parent.getItemAtPosition(pos);
				if (!name.equals(DOING)) {
					doingFilter = name;
				} else {
					doingFilter = null;
				}
				
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
				
			}
		});
	}

	/**
	 * 
	 */
	private void makeWhoSpinner() {
		Spinner spinner = new Spinner(this);
		String[] names = EmotionActivity.DATABASE.getChosenContactNames();
		String[] options = new String[names.length + 1];
		options[0] = WHO;
		int i = 1;
		for(String name: names) {
			options[i] = name;
			i++;
		}
		ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<String>(
				this, android.R.layout.simple_spinner_item, options) {
			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				View v = super.getView(position, convertView, parent);

				((TextView) v).setTextSize(25);
				((TextView) v).setTextColor(getResources().getColorStateList(
						R.color.White));
				return v;
			}
		};
		spinnerArrayAdapter
				.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

		spinner = (Spinner) findViewById(R.id.whoSpinner);
		spinner.setAdapter(spinnerArrayAdapter);
		spinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int pos, long id) {
				String name = (String) parent.getItemAtPosition(pos);
				if (!name.equals(WHO)) {
					whoFilter = name;
				} else {
					whoFilter = null;
				}
				
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
				
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
						.readWithFilters(timeFilter, locationFilter, whoFilter,
								doingFilter);
				transformToSelectionCount(results);
				Intent intent = new Intent(getApplicationContext(),
						VisualizationActivity.class);
				intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP
						| Intent.FLAG_ACTIVITY_SINGLE_TOP);
				if (timeFilter == null)
					timeFilter = TIME;
				if (locationFilter == null)
					locationFilter = LOCATION;
				if (whoFilter == null)
					whoFilter = WHO;
				if (doingFilter == null)
					doingFilter = DOING;
				intent.putExtra("Filter", timeFilter + " > " + locationFilter
						+ " > " + whoFilter + " > " + doingFilter);

				startActivity(intent);

				finish();

			}
		});
	}

	/**
	 * 
	 */
	private void makeTimeSpinner() {
		Spinner spinner = new Spinner(this);
		String[] times = { TIME, TODAY, WEEK, MONTH };
		ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<String>(
				this, android.R.layout.simple_spinner_item, times) {
			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				View v = super.getView(position, convertView, parent);

				((TextView) v).setTextSize(25);
				((TextView) v).setTextColor(getResources().getColorStateList(
						R.color.White));
				return v;
			}
		};
		spinnerArrayAdapter
				.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

		spinner = (Spinner) findViewById(R.id.timeSpinner);
		spinner.setAdapter(spinnerArrayAdapter);
		spinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int pos, long id) {
				String name = (String) parent.getItemAtPosition(pos);
				System.out.println("TIME: " + name);
				if (!name.equals(TIME)) {
					timeFilter = name;
				} else {
					timeFilter = null;
				}
				
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
				
			}
		});
	}

	/**
	 * 
	 */
	private void makeLocationSpinner() {
		Spinner spinner = new Spinner(this);
		ArrayAdapter<String> spinnerArrayAdapter = new ArrayAdapter<String>(
				this, android.R.layout.simple_spinner_item,
				makeLocationSpinnerOptions()) {
			@Override
			public View getView(int position, View convertView, ViewGroup parent) {
				View v = super.getView(position, convertView, parent);

				((TextView) v).setTextSize(25);
				((TextView) v).setTextColor(getResources().getColorStateList(
						R.color.White));
				return v;
			}
		};
		spinnerArrayAdapter
				.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);

		spinner = (Spinner) findViewById(R.id.locationSpinner);
		spinner.setAdapter(spinnerArrayAdapter);
		spinner.setOnItemSelectedListener(new OnItemSelectedListener() {

			@Override
			public void onItemSelected(AdapterView<?> parent, View view,
					int pos, long id) {
				String name = (String) parent.getItemAtPosition(pos);
				if (!name.equals(LOCATION)) {
					locationFilter = name;
				} else {
					locationFilter = null;
				}
				
			}

			@Override
			public void onNothingSelected(AdapterView<?> arg0) {
				// TODO Auto-generated method stub
				
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
		for (String location : locations) {
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
}
