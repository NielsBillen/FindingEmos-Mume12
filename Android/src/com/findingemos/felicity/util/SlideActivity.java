package com.findingemos.felicity.util;

import android.app.Activity;
import android.content.Intent;

import com.findingemos.felicity.R;

/**
 * Klasse van stackoverflow om terug slide transities te hebben tussen de
 * schermen.
 * 
 * Aangepast naar standaard android methodes.
 * http://stackoverflow.com/questions/
 * 10108192/android-ics-activity-transition-from-fade-in-out-back-to-slide
 * 
 * @author Robin
 * 
 */
public abstract class SlideActivity extends Activity {

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		overridePendingTransition(R.anim.lefttoright_emotion,
				R.anim.righttoleft_emotion);
	}

	@Override
	public void startActivity(Intent intent) {
		super.startActivity(intent);
		overridePendingTransition(R.anim.lefttoright_emotion,
				R.anim.righttoleft_emotion);
	}

	@Override
	public void finish() {
		super.finish();
		overridePendingTransition(R.anim.lefttoright_emotion,
				R.anim.righttoleft_emotion);
	}

}