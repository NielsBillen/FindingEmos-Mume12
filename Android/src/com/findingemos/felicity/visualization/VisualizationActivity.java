package com.findingemos.felicity.visualization;

import java.util.Arrays;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.findingemos.felicity.R;
import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.general.ActivityIndicator;
import com.findingemos.felicity.general.ActivitySwitchListener;
import com.findingemos.felicity.util.AutoResizeTextView;
import com.findingemos.felicity.util.SimpleSwipeListener;
import com.findingemos.felicity.util.SlideActivity;
import com.findingemos.felicity.util.Swipeable;

/**
 * Deze activiteit geeft de resultaten van de gebruiker visueel weer.
 * 
 * @author Niels
 * @version 0.1
 */
public class VisualizationActivity extends SlideActivity implements Swipeable {

	private final static int VISUALIZATION_ACTIVITY_CODE = 2;

	private static Emotion[] currentData = Emotion.values();
	
	private static String filterString;
	
	public static void resetFiler() {
		filterString = null;
	}

	public static Emotion[] getCurrentData() {
		return currentData;
	}

	public static void setCurrentData(Emotion[] currentData) {
		VisualizationActivity.currentData = currentData;
	}

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

		AutoResizeTextView locationView = (AutoResizeTextView) findViewById(R.id.filter);
		try {
			filterString = getIntent().getExtras().getString("Filter");
			locationView.setText(filterString);
		} catch (NullPointerException e) {
			// enkel als er nog nooit een filter is ingesteld.
			if (filterString == null) {
				String TIME = getApplicationContext().getResources().getString(
						R.string.visualizations_time);
				String LOCATION = getApplicationContext().getResources()
						.getString(R.string.visualizations_location);
				String WHO = getApplicationContext().getResources().getString(
						R.string.visualizations_who);
				String DOING = getApplicationContext().getResources()
						.getString(R.string.visualizations_doing);
				filterString = TIME + " > " + LOCATION + " > " + WHO
						+ " > " + DOING;
				locationView.setText(filterString);
			} else {
				locationView.setText(filterString);
			}
		}

		initActivityIndicator();
		initFilter();
		addSwipeListener();

		drawVisualizations();

		overridePendingTransition(R.anim.lefttoright_visualization,
				R.anim.righttoleft_visualization);
	}

	/**
	 * Initialiseert de activity indicator.
	 */
	private void initActivityIndicator() {
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
	}

	/**
	 * Voegt de swipe listener toe.
	 */
	private void addSwipeListener() {
		LinearLayout view = (LinearLayout) findViewById(R.id.visualization_layout);
		view.setOnTouchListener(new SimpleSwipeListener(this));
	}

	/**
	 * Initialiseert de spinner.
	 */
	private void initFilter() {
		final LinearLayout linearLayout = (LinearLayout) findViewById(R.id.topSelector);
		linearLayout.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent intent = new Intent(getApplicationContext(),	FilterActivity.class);
				startActivityForResult(intent, VISUALIZATION_ACTIVITY_CODE);
				finish();
			}
		});
	}

	// ////////////////////////////////////////////////////
	// / Visualisatie ///
	// ////////////////////////////////////////////////////

	/**
	 * Deze methode tekent de visualisatie.
	 * 
	 * @param values
	 */
	@SuppressWarnings("deprecation")
	public void drawVisualizations() {
		// Bepaald de maximaal mogelijke breedte van de balk.
		Display display = getWindowManager().getDefaultDisplay();
		int width = display.getWidth();
		int maxWidth = width - 72 - 16 - 72;

		// Haal de count van de emotions op.
		Emotion[] sorted = currentData;
		Arrays.sort(sorted, Emotion.getComparator());
		LinearLayout linearLayout = (LinearLayout) findViewById(R.id.visualization_layout);

		// Bepaal wat de totale en maximale count is.
		int totalCount = 0;
		int maxCount = 0;
		for (int i = 0; i < sorted.length; i++) {
			totalCount += sorted[i].getSelectionCount();
			if (sorted[i].getSelectionCount() > maxCount)
				maxCount = sorted[i].getSelectionCount();
		}
		if (totalCount < 1) {
			totalCount = 1;
			maxCount = 1;
		}

		// Tekenen maar.
		for (int i = 0; i < sorted.length; i++) {
			Emotion emotion = sorted[i];
			drawVisualisationForEmotion(emotion, maxWidth, linearLayout,
					totalCount, maxCount);
		}
	}

	/**
	 * Deze methode visualiseert voor de meegegeven emotion hoe vaak deze
	 * geselecteerd is;
	 * 
	 * @param emotion
	 *            De emotie in kwestie.
	 * @param maxWidth
	 *            De maximale breedte van de balk.
	 * @param ll
	 *            De LinearLayout waarin de visualisatie moet weergegeven
	 *            worden.
	 * @param totalCount
	 *            Het totaal aantal geselecteerde emoties.
	 * @param maxCount
	 *            Het maximaal aantal keer dat 1 emotie geselecteerd is.
	 */
	@SuppressWarnings("deprecation")
	private void drawVisualisationForEmotion(Emotion emotion, int maxWidth,
			LinearLayout ll, int totalCount, int maxCount) {
		LinearLayout emoVis = new LinearLayout(getApplicationContext());
		int barWidth = Math.round(maxWidth * emotion.getSelectionCount()
				/ maxCount);
		int percentage = emotion.getSelectionCount() * 100 / totalCount;

		drawEmoticon(emotion, emoVis);
		drawBar(emoVis, barWidth);
		drawPercentage(percentage, totalCount, emoVis);

		LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
				android.view.ViewGroup.LayoutParams.FILL_PARENT, 64);
		lp.setMargins(5, 8, 5, 8);
		ll.addView(emoVis, lp);
	}

	/**
	 * Deze methode tekent de meegegeven emotion op het scherm.
	 * 
	 * @param emotion
	 *            De emotie in kwestie.
	 * @param emoVis
	 *            De LinearLayout waarin de visualisatie moet weergegeven
	 *            worden.
	 */
	private void drawEmoticon(Emotion emotion, LinearLayout emoVis) {
		ImageView emo = new ImageView(getApplicationContext());
		emo.setImageResource(emotion.getLowResolutionResourceId());
		LinearLayout.LayoutParams emoLayout = new LinearLayout.LayoutParams(56,
				56);
		emoLayout.setMargins(8, 8, 4, 8);
		emoVis.addView(emo, emoLayout);
	}

	/**
	 * Deze methode tekent voor de meegegeven emotion de balk op scherm.
	 * 
	 * @param emoVis
	 *            De LinearLayout waarin de visualisatie moet weergegeven
	 *            worden.
	 * @param barWidth
	 *            De breedte van de balk.
	 */
	private void drawBar(LinearLayout emoVis, int barWidth) {
		View bar = new View(getApplicationContext());
		LinearLayout.LayoutParams barLayout = new LinearLayout.LayoutParams(0,
				40);
		barLayout.setMargins(4, 16, 4, 8);
		bar.setBackgroundResource(R.color.Gray);
		barLayout.width = barWidth;

		Animation barAnimation = AnimationUtils.loadAnimation(this,
				R.anim.visualisation_barview);
		bar.startAnimation(barAnimation);

		emoVis.addView(bar, barLayout);
	}

	/**
	 * Deze methode tekent voor de meegegeven emotion zijn percentage op het
	 * scherm;
	 * 
	 * @param percentage
	 *            Het percentage dat de emotie geselecteerd is.
	 * @param emoVis
	 *            De LinearLayout waarin de visualisatie moet weergegeven
	 *            worden.
	 * @param totalCount
	 *            Het totaal aantal geselecteerde emoties.
	 */
	private void drawPercentage(int percentage, int totalCount,
			LinearLayout emoVis) {
		AutoResizeTextView text = new AutoResizeTextView(getApplicationContext());
//		LinearLayout.LayoutParams textLayout = new LinearLayout.LayoutParams(
//				64, 64);
		LinearLayout.LayoutParams llp = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
		llp.setMargins(4, 16, 8, 0);
//	    llp.setMargins(50, 0, 0, 0); // llp.setMargins(left, top, right, bottom);
		text.setText(percentage + " %");
		text.setTextColor(Color.parseColor("#bdbdbd"));
		emoVis.addView(text, llp);
//		emoVis.addView(text);
	}

	// ////////////////////////////////////////////////////
	// / Swipeable ///
	// ////////////////////////////////////////////////////

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
		finish();
	}
}
