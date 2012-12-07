package com.findingemos.felicity.visualization;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.view.Menu;

import com.findingemos.felicity.R;

public class FilterActivity extends FragmentActivity {

	private String TIME;
	private String LOCATION;
	private String WHO;
	private String DOING;

	private String[] currentFilter = new String[4];


	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.filter_activity);

		TIME = getApplicationContext().getResources().getString(
				R.string.visualizations_time);
		LOCATION = getApplicationContext().getResources().getString(
				R.string.visualizations_location);
		WHO = getApplicationContext().getResources().getString(
				R.string.visualizations_who);
		DOING = getApplicationContext().getResources().getString(
				R.string.visualizations_doing);

		currentFilter[0] = TIME;
		currentFilter[1] = LOCATION;
		currentFilter[2] = WHO;
		currentFilter[3] = DOING;

		ArrowButton leftTime = (ArrowButton) findViewById(R.id.timeArrowLeft);
		leftTime.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightTime = (ArrowButton) findViewById(R.id.timeArrowRight);
		rightTime.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner timeSpinner = (OptionSpinner) findViewById(R.id.timeSpinner);
		timeSpinner.setLeftButton(leftTime);
		timeSpinner.setRightButton(rightTime);
		timeSpinner.setOptions(TIME,"Today","Week");
		timeSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				currentFilter[0] = name;
			}
		});

		ArrowButton leftLocation = (ArrowButton) findViewById(R.id.locationArrowLeft);
		leftLocation.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightLocation = (ArrowButton) findViewById(R.id.locationArrowRight);
		rightLocation.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner locationSpinner = (OptionSpinner) findViewById(R.id.locationSpinner);
		locationSpinner.setLeftButton(leftLocation);
		locationSpinner.setRightButton(rightLocation);
		locationSpinner.setOptions(LOCATION,"Lanaken");
		locationSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				currentFilter[1] = name;
			}
		});

		ArrowButton leftWho = (ArrowButton) findViewById(R.id.whoArrowLeft);
		leftWho.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightWho = (ArrowButton) findViewById(R.id.whoArrowRight);
		rightWho.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner whoSpinner = (OptionSpinner) findViewById(R.id.whoSpinner);
		whoSpinner.setLeftButton(leftWho);
		whoSpinner.setRightButton(rightWho);
		whoSpinner.setOptions(WHO,"Robin");
		locationSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				currentFilter[2] = name;
			}
		});

		ArrowButton leftDoing = (ArrowButton) findViewById(R.id.doingArrowLeft);
		leftDoing.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton rightDoing = (ArrowButton) findViewById(R.id.doingArrowRight);
		rightDoing.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner doingSpinner = (OptionSpinner) findViewById(R.id.doingSpinner);
		doingSpinner.setLeftButton(leftDoing);
		doingSpinner.setRightButton(rightDoing);
		doingSpinner.setOptions(DOING,"Work");
		doingSpinner.addListener(new SpinnerListener() {

			@Override
			public void optionChanged(int index, String name) {
				currentFilter[3] = name;
			}
		});
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.activity_main, menu);
		return true;
	}
}
