package com.findingemos.felicity.emoticon;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Align;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.util.Log;
import android.view.DragEvent;
import android.view.View;

import com.findingemos.felicity.R;
import com.findingemos.felicity.util.FadeThread;
import com.findingemos.felicity.util.ImageScaler;
import com.findingemos.felicity.util.MultiThreadAccesView;

/**
 * This class is responsable for drawing the emoticon to which the other
 * emoticons can be dragged.<br>
 * <br>
 * The main functionality for drawing is place in the onDraw() method. This
 * method is called when the content of this view is drawn.<br>
 * <br>
 * In order to gain more performance, a lot of the variables are allocated in
 * the fields (this is suggested on the Android Website as a good practice).
 * 
 * @author Niels
 * @version 0.1
 */
public class EmotionDrawer extends View implements EmotionSelectionListener,
		MultiThreadAccesView {
	// The current emoticon
	private Emotion emotion;

	/**
	 * Field in which the emoticon with the empty face is stored.<br>
	 * <br>
	 * This bitmap will be instantiated when the size of this View changes. We
	 * cannot initialize it in the constructor because the size of this view
	 * will not be determined yet (getWidth() and getHeight() will return zero).<br>
	 * <br>
	 * Therefore, the bitmap is created and scaled in the onSizeChanged()
	 * method.
	 */
	private Bitmap bitmap;

	// The resource for the image.
	private int resourceId = R.drawable.empty_big;

	/**
	 * A scale factor for the emptyEmoticon. When it is created, the width and
	 * height of the emoticon will be scaled by this factor so it doesn't fill
	 * up the entire view, but leaves some space around the borders.
	 */
	private final double SCALE_FACTOR = 0.75;

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

	/**
	 * A paint object for drawing the text "Felicity" and the names of the
	 * emoticons.
	 */
	private final Paint TEXTPAINTER = new Paint(Paint.ANTI_ALIAS_FLAG);

	// A paint object for drawing the main emoticon.
	private final Paint EMOTICONPAINTER = new Paint(Paint.ANTI_ALIAS_FLAG);

	// A paint object for drawing the help text
	private final Paint HELPPAINTER = new Paint(Paint.ANTI_ALIAS_FLAG);

	// The string that indicates the emotion.
	private String emoticonDescription = "";

	// The size of the font.
	private final int FONT_SIZE = 48;

	// The size of the font.
	private final int HELP_SIZE = 20;

	// Whether the image is dirty and needs to be recreated.
	private boolean isDirty = true;

	// The current thread that executes fading.
	private FadeThread emoticonDescriptionFade;

	// The timeout for text changes
	private final long textTimeout = 250;

	// The timeout for emoticon changes
	private final long emoticonChange = 500;

	// The number of fps for the animation.
	private final int fps = 60;

	// The average sleeptime for the animation.
	private final long sleepTime = (long) (1000.0 / fps);

	// The time of the last update
	private long lastUpdate;

	// The help text
	private String helpText;

	/**
	 * Creates a new EmoticonDrawer within the given context.
	 * 
	 * @param context
	 *            The context to create this object in.
	 */
	public EmotionDrawer(Context context) {
		super(context);
		init();
	}

	/**
	 * Creates a new EmoticonDrawer within the given context and with the given
	 * attribute set.
	 * 
	 * @param context
	 *            The context to create this object in.
	 * @param set
	 *            The attribute set to initialize this drawer with.
	 */
	public EmotionDrawer(Context context, AttributeSet set) {
		super(context, set);
		init();
	}

	/**
	 * Initializes constant variables used for drawing.
	 */
	private void init() {
		TEXTPAINTER.setTextAlign(Align.CENTER);
		TEXTPAINTER.setColor(Color.WHITE);
		TEXTPAINTER.setTextSize(FONT_SIZE);

		HELPPAINTER.setTextAlign(Align.CENTER);
		HELPPAINTER.setColor(Color.WHITE);
		HELPPAINTER.setTextSize(HELP_SIZE);

		EMOTICONPAINTER.setAlpha(255);

		if (EmotionActivity.DRAG_AND_DROP)
			helpText = "Drag and drop your feelings\non the empty face";
		else
			helpText = "Double tap on the emoticon\nto change your emotion";

		// new Thread() {
		// public void run() {
		// try {
		// sleep(5000);
		// } catch (InterruptedException e) {
		// }
		// ;
		// new FadeThread(EmotionDrawer.this, HELPPAINTER, 1000, 60) {
		// /*
		// * (non-Javadoc)
		// *
		// * @see
		// * com.findingemos.felicity.util.FadeThread#onInvisible()
		// */
		// @Override
		// public void onInvisible() {
		// helpText = "";
		// HELPPAINTER.setAlpha(255);
		//
		// }
		// }.start();
		// }
		// }.start();
	}

	/**
	 * Updates the resources when the canvas changes size.
	 * 
	 * @param w
	 *            The new width of the image.
	 * @param h
	 *            The new height of the image.
	 */
	private void updateImage(int w, int h) {
		if (!isDirty)
			return;
		isDirty = false;

		if (w > 0 && h > 0) {
			int ww = (int) Math.ceil(w * SCALE_FACTOR);
			int hh = (int) Math.ceil(h * SCALE_FACTOR);

			Bitmap fullImage = BitmapFactory.decodeResource(getResources(),
					resourceId);
			bitmap = ImageScaler.convert(fullImage, ww, hh);
		} else
			isDirty = true;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View#onDraw(android.graphics.Canvas)
	 */
	@Override
	protected void onDraw(Canvas canvas) {
		super.onDraw(canvas);

		/*
		 * Find the size of the canvas. Read the comments of the "rect" field to
		 * see why I do this code.
		 */
		if (!canvas.getClipBounds(rect))
			return;

		/*
		 * Draw the emoticon text
		 */
		float emoticonSeperation = TEXTPAINTER.descent() - TEXTPAINTER.ascent();
		canvas.drawText(emoticonDescription, rect.centerX(),
				emoticonSeperation, TEXTPAINTER);

		/*
		 * Draw help text
		 */
		String[] strings = helpText.split("\n");
		float helpSeperation = HELPPAINTER.descent() - HELPPAINTER.ascent();
		float drawY = rect.height() - (strings.length) * helpSeperation;

		for (String text : strings) {
			canvas.drawText(text, rect.centerX(), drawY, HELPPAINTER);
			drawY += helpSeperation;
		}

		/*
		 * Update the image when it is dirty.
		 */
		int imageHeight = (int) (rect.height() - 2 * emoticonSeperation - (strings.length)
				* helpSeperation);
		updateImage(rect.width(), imageHeight);

		/*
		 * Skip when the emoticon is null.
		 */
		if (bitmap == null)
			return;

		// Calculate the width and height.
		int x = rect.centerX() - bitmap.getWidth() / 2;
		int y = (int) (1.5 * emoticonSeperation);

		/*
		 * Draw the face.
		 */
		canvas.drawBitmap(bitmap, x, y, EMOTICONPAINTER);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View.OnDragListener#onDrag(android.view.View,
	 * android.view.DragEvent)
	 */
	@SuppressLint("NewApi")
	@Override
	public boolean onDragEvent(DragEvent event) {
		if (!EmotionActivity.DRAG_AND_DROP)
			return false;
		Object localState = event.getLocalState();
		if (!(localState instanceof EmotionView))
			return false;
		EmotionView view = (EmotionView) localState;
		final Emotion emoticon = view.getEmoticon();

		if (event.getAction() == DragEvent.ACTION_DRAG_STARTED)
			return true;
		else if (event.getAction() == DragEvent.ACTION_DROP) {
			// emoticon.incrementSelectionCount();
			view.setVisibility(View.VISIBLE);
			Log.i("Emoticon", "Emoticon: " + emoticon.getName()
					+ " was dragged succesfully!");
			view.notifyDoubleTapped();
			FadeThread imageUpdater = new FadeThread(this, EMOTICONPAINTER,
					emoticonChange, fps) {
				/*
				 * (non-Javadoc)
				 * 
				 * @see
				 * com.findingemos.felicity.emoticon.EmoticonDrawer.FadeThread#
				 * onInvisible()
				 */
				@Override
				public void onInvisible() {
					resourceId = emoticon.getHighResolutionResourceId();
					isDirty = true;
				}
			};
			imageUpdater.start();
			emotion = emoticon;
			return true;
		} else if (event.getAction() == DragEvent.ACTION_DRAG_ENDED) {
			view.setVisibility(View.VISIBLE);
			Log.i("Emoticon", "Emoticon: " + emoticon.getName()
					+ " was dragged succesfully!");
			view.notifyDoubleTapped();
			return true;
		}
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.emoticon.EmoticonSelectionListener#
	 * onEmoticonSelected(com.findingemos.felicity.emoticon.Emoticon)
	 */
	@Override
	public void onEmotionSelected(final Emotion emoticon) {
		if (emoticonDescription.equals(""))
			TEXTPAINTER.setAlpha(0);
		if (emoticonDescriptionFade != null)
			emoticonDescriptionFade.abort();
		emoticonDescriptionFade = new FadeThread(this, TEXTPAINTER,
				textTimeout, fps) {
			/*
			 * (non-Javadoc)
			 * 
			 * @see com.findingemos.felicity.emoticon.EmoticonDrawer.FadeThread#
			 * onInvisible()
			 */
			@Override
			public void onInvisible() {
				emoticonDescription = emoticon.getName();
			}
		};
		emoticonDescriptionFade.start();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.emoticon.EmoticonSelectionListener#
	 * onEmoticonDeselected(com.findingemos.felicity.emoticon.Emoticon)
	 */
	@Override
	public void onEmotionDeselected(Emotion emoticon) {
		if (emoticonDescriptionFade != null)
			emoticonDescriptionFade.abort();
		emoticonDescriptionFade = new FadeThread(this, TEXTPAINTER,
				textTimeout, fps) {
			/*
			 * (non-Javadoc)
			 * 
			 * @see com.findingemos.felicity.emoticon.EmoticonDrawer.FadeThread#
			 * onInvisible()
			 */
			@Override
			public void onInvisible() {

				emoticonDescription = emotion == null ? "" : emotion.getName();
				TEXTPAINTER.setAlpha(0);
			}
		};
		emoticonDescriptionFade.start();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see com.findingemos.felicity.emoticon.EmoticonSelectionListener#
	 * onEmoticonDoubleTapped(com.findingemos.felicity.emoticon.Emoticon)
	 */
	@Override
	public void onEmotionDoubleTapped(final Emotion emoticon) {
		// emoticon.incrementSelectionCount();
		Log.i("Emoticon", "Emoticon: " + emoticon.getName()
				+ " was double tapped succesfully!");
		FadeThread imageUpdater = new FadeThread(this, EMOTICONPAINTER,
				emoticonChange, fps) {
			/*
			 * (non-Javadoc)
			 * 
			 * @see com.findingemos.felicity.emoticon.EmoticonDrawer.FadeThread#
			 * onInvisible()
			 */
			@Override
			public void onInvisible() {
				resourceId = emoticon.getHighResolutionResourceId();
				isDirty = true;
			}
		};
		imageUpdater.start();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * com.findingemos.felicity.util.MultiThreadAccesView#requestSyncUpdate()
	 */
	@Override
	public void requestSyncUpdate() {
		long currentTime = System.currentTimeMillis();

		if (currentTime - lastUpdate < sleepTime)
			return;
		lastUpdate = currentTime;
		postInvalidate();
	}
}