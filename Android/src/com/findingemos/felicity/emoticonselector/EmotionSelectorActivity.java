package com.findingemos.felicity.emoticonselector;

import android.app.Activity;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;

import com.findingemos.felicity.R;
import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.emoticon.EmotionSelectionListener;

public class EmotionSelectorActivity extends Activity {
	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.Activity#onCreate(android.os.Bundle)
	 */
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		// This method is called when the activity is first created.
		super.onCreate(savedInstanceState);

		/*
		 * These two method calls are suggested by a site to avoid the blocks
		 * when drawing gradients. These lines should make the transition
		 * between the colors more smoothly.
		 */
		getWindow().setFormat(PixelFormat.RGBA_8888);
		getWindow().addFlags(WindowManager.LayoutParams.FLAG_DITHER);

		/*
		 * This method sets how this view should be constructed. These details
		 * are specified in "emotion.xml". To access that xml file, you use the
		 * variables in the autogenerated "R" class.
		 */
		setContentView(R.layout.emoticonselection_activity);
		Log.i("EmotionSelectorActivity", "i");
		
		overridePendingTransition(R.anim.uptodown_emotionselection,
				R.anim.downtoup_emotionselection);
		
		initialize();
	}

	/**
	 * 
	 */
	private void initialize() {
		// Gallery
		EmotionGallery gallery = new EmotionGallery(this);
		gallery.addListener(new EmotionSelectionListener() {
				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * com.findingemos.felicity.emoticon.EmoticonSelectionListener#
				 * onEmoticonSelected
				 * (com.findingemos.felicity.emoticon.Emoticon)
				 */
				@Override
				public void onEmotionSelected(Emotion emoticon) {			
					Intent result = new Intent();
					result.putExtra("emotion", emoticon.getUniqueId());
					setResult(RESULT_OK, result);
					finish();
				}

				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * com.findingemos.felicity.emoticon.EmoticonSelectionListener#
				 * onEmoticonDoubleTapped
				 * (com.findingemos.felicity.emoticon.Emoticon)
				 */
				@Override
				public void onEmotionDoubleTapped(Emotion emoticon) {
				}

				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * com.findingemos.felicity.emoticon.EmoticonSelectionListener#
				 * onEmoticonDeselected
				 * (com.findingemos.felicity.emoticon.Emoticon)
				 */
				@Override
				public void onEmotionDeselected(Emotion emoticon) {
				}
			});
		LinearLayout layout = (LinearLayout) findViewById(R.id.EmotionSelectionLinearLayout);
		layout.addView(gallery,new LayoutParams(LayoutParams.MATCH_PARENT,LayoutParams.MATCH_PARENT));
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.app.Activity#onCreateContextMenu(android.view.ContextMenu,
	 * android.view.View, android.view.ContextMenu.ContextMenuInfo)
	 */
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.activity_emotion, menu);
		return true;
	}
}
