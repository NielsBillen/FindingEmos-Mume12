package com.findingemos.felicity.emoticonselector;

import java.util.ArrayList;
import java.util.Arrays;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.emoticon.EmotionSelectionListener;
import com.findingemos.felicity.util.ImageScaler;
import com.findingemos.felicity.util.ListenerContainer;

/**
 * Gallery which displays all of the emotions with their descriptions.
 * 
 * @author Niels
 * @version 0.1
 */
public class EmotionGallery extends View implements
		ListenerContainer<EmotionSelectionListener> {
	// Stores the number of icons per row.
	private int iconsPerRow = 4;

	/**
	 * Optimization recommended by the compiler. It is not good to allocate a
	 * lot of objects in the onDraw() method since it is called a lot of time.
	 * Therefore, I allocate a rectangle here and in the onDraw() method I use.<br>
	 * <br>
	 * if (!canvas.getClipBounds(rect)) return true;<br>
	 * <br>
	 * Instead of doing:<br>
	 * <br>
	 * Rect rect = canvas.getClipBounds();
	 */
	private final Rect rect = new Rect();

	// Whether the resources need an update.
	private boolean isDirty = true;
	// Sorted list with emotions.
	private Emotion[] emoticons;
	// The bitmaps with the images of the emotions;
	private Bitmap[] bitmaps;
	// Paint object for anti-aliased text
	private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
	// List with emotion selection listeners.
	private ArrayList<EmotionSelectionListener> listeners = new ArrayList<EmotionSelectionListener>();

	// Stores the number of rows.
	private int nbOfRows;
	float optimalIconWidth;
	float optimalIconHeight;

	/**
	 * 
	 * @param context
	 */
	public EmotionGallery(Context context) {
		super(context);
		init();
	}

	/**
	 * 
	 * @param context
	 * @param set
	 */
	public EmotionGallery(Context context, AttributeSet set) {
		super(context);
		init();
	}

	/**
	 * 
	 */
	private void init() {
		emoticons = Emotion.values();
		Arrays.sort(emoticons, Emotion.getComparator());
		nbOfRows = (int) Math.ceil((double) emoticons.length
				/ (double) iconsPerRow);
		paint.setColor(Color.WHITE);
		paint.setTextAlign(Align.CENTER);
		paint.setTextSize(16);
	}

	/**
	 * 
	 * @param w
	 * @param h
	 */
	private void update(int w, int h) {
		if (!isDirty)
			return;
		if (w == 0 || h == 0 || emoticons == null)
			return;
		isDirty = false;

		// Optimal size for the icons.
		optimalIconWidth = w / iconsPerRow;
		optimalIconHeight = h / (nbOfRows + 1);
		int iconSize = (int) Math.min(optimalIconWidth - 16,
				optimalIconHeight - 16);

		// Create the bitmaps
		bitmaps = new Bitmap[emoticons.length];
		for (int i = 0; i < emoticons.length; ++i) {
			Bitmap fullImage = BitmapFactory.decodeResource(getResources(),
					emoticons[i].getLowResolutionResourceId());
			bitmaps[i] = ImageScaler.convert(fullImage, iconSize, iconSize);
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View#onDraw(android.graphics.Canvas)
	 */
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);

		if (!canvas.getClipBounds(rect))
			return;
		update(canvas.getWidth(), canvas.getHeight());

		if (isDirty)
			return;
		float drawX = optimalIconWidth / 2;
		float drawY = optimalIconHeight / 2;
		int index = 0;
		for (int row = 0; row < nbOfRows; ++row) {
			drawX = optimalIconWidth / 2;
			for (int icon = 0; icon < iconsPerRow; ++icon) {
				if (index < emoticons.length) {
					Bitmap map = bitmaps[index];
					canvas.drawBitmap(bitmaps[index], drawX - map.getWidth()
							/ 2, drawY - map.getHeight() / 2, null);
					canvas.drawText(emoticons[index].getName(), drawX, drawY
							+ optimalIconHeight / 2, paint);
					index++;
					drawX += optimalIconWidth;
				}
			}
			drawY += optimalIconHeight;
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View#onTouchEvent(android.view.MotionEvent)
	 */
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		if (event.getAction() == MotionEvent.ACTION_DOWN) {
			int column = (int) (event.getX() / optimalIconWidth);
			int row = (int) (event.getY() / optimalIconHeight);
			int index = row * iconsPerRow + column;
			if (index < emoticons.length) {
				Emotion emoticon = emoticons[index];
				emoticon.incrementSelectionCount();
				notifySelection(emoticon);
			}
		}
		return super.onTouchEvent(event);
	}

	/**
	 * 
	 * @param listener
	 */
	public void addListener(EmotionSelectionListener listener) {
		if (listener != null)
			listeners.add(listener);
	}

	/**
	 * 
	 */
	public void removeListener(EmotionSelectionListener listener) {
		listeners.remove(listener);
	}

	/**
	 * 
	 * @param emoticon
	 */
	public void notifySelection(Emotion emoticon) {
		for (EmotionSelectionListener listener : listeners)
			listener.onEmotionSelected(emoticon);
	}
}
