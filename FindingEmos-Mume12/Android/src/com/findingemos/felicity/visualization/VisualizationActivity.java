package com.findingemos.felicity.visualization;

import android.app.Activity;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.WindowManager;
import android.widget.ImageView;

import com.findingemos.felicity.R;
import com.findingemos.felicity.emoticon.EmotionActivity;
import com.findingemos.felicity.general.ActivityIndicator;
import com.findingemos.felicity.general.ActivitySwitchListener;
import com.findingemos.felicity.util.SimpleSwipeListener;
import com.findingemos.felicity.util.Swipeable;

/**
 * 
 * @author Niels
 * @version 0.1
 */
public class VisualizationActivity extends Activity implements Swipeable {
	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.Activity#onCreate(android.os.Bundle)
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		getWindow().setFormat(PixelFormat.RGBA_8888);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_DITHER);

		setContentView(R.layout.visualization_activity);

		/*
		 * Add listeners to the activity indicator
		 */
		ActivityIndicator indicator = (ActivityIndicator) findViewById(R.id.activityIndicator);
		indicator.setCurrentActivity(1);
		indicator.addListener(new ActivitySwitchListener() {
			/*
			 * (non-Javadoc)
			 * 
			 * @see com.findingemos.felicity.general.ActivitySwitchListener#
			 * activitySelected(int)
			 */
			@Override
			public void activitySelected(int index) {
				if (index == 0)
					switchToEmotionActivity();

			}
		});

		/*
		 * Manage the buttons.
		 */
		ArrowButton left = (ArrowButton) findViewById(R.id.topArrowLeft);
		left.setArrowDirection(ArrowButton.DIRECTION_LEFT);
		ArrowButton right = (ArrowButton) findViewById(R.id.topArrowRight);
		right.setArrowDirection(ArrowButton.DIRECTION_RIGHT);
		OptionSpinner spinner = (OptionSpinner) findViewById(R.id.topSpinner);
		spinner.setLeftButton(left);
		spinner.setRightButton(right);
		spinner.setOptions("Pie chart", "Bar chart", "Timeline", "Map");
		/*
		 * Add a swipe listener to the chart.
		 */
		ImageView view = (ImageView) findViewById(R.id.dummyChart);
		view.setOnTouchListener(new SimpleSwipeListener(this));

		overridePendingTransition(R.anim.lefttoright_visualization,
				R.anim.righttoleft_visualization);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.Activity#onCreateOptionsMenu(android.view.Menu)
	 */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		return true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.general.SimpleSwipeListener#onSwipeLeft()
	 */
	@Override
	public void onSwipeLeft() {
		Log.d("--scrolled--", "scrolled to the right!");
		switchToEmotionActivity();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.general.SimpleSwipeListener#onSwipeRight()
	 */
	@Override
	public void onSwipeRight() {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.util.Swipeable#onSwipeUp()
	 */
	@Override
	public void onSwipeUp() {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.util.Swipeable#onSwipeDown()
	 */
	@Override
	public void onSwipeDown() {
	}

	/**
	 * 
	 */
	private void switchToEmotionActivity() {
		Intent intent = new Intent(this, EmotionActivity.class);
		startActivity(intent);
	}
}
