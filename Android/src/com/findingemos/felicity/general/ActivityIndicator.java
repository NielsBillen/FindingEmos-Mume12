package com.findingemos.felicity.general;

import java.util.ArrayList;

import com.findingemos.felicity.R;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.View;

/**
 * A view that shows the dots that indicate in which activity we are at the
 * moment.
 * 
 * @author Niels
 * @version 0.1
 */
public class ActivityIndicator extends View {
	/**
	 * A paint object for drawing the outline of the dots.
	 */
	private final Paint DOTPAINTER = new Paint(Paint.ANTI_ALIAS_FLAG);
	/**
	 * A paint object for drawing a filled dot.
	 */
	private final Paint CURRENTPAINTER = new Paint(Paint.ANTI_ALIAS_FLAG);

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
	private final Rect RECT = new Rect();

	// The total number of dots that need to be drawn (one per activity)
	private final int NB_OF_DOTS = 2;

	// The radius of a dot
	private final int DOT_RADIUS = 8;

	// The spacing between two dots.
	private final int DOT_SPACING = 16;

	// The width of the lines when drawing the outline of a dot.
	private final int STROKE_WIDTH = 2;

	// The current dot.
	private int current_dot = 0;

	// Rectangles for touch listeners
	private final ArrayList<Rect> touchRectangles = new ArrayList<Rect>();

	// Flat to check whether the rectangles are dirty.
	private boolean isDirty = true;

	// Listeners for switches in activity.
	private ArrayList<ActivitySwitchListener> listeners = new ArrayList<ActivitySwitchListener>();

	/**
	 * Creates a new ActivityIndicator in the given context.
	 * 
	 * @param context
	 *            The context to create the ActivityIndicator in.
	 */
	public ActivityIndicator(Context context) {
		super(context);
		init();
	}

	/**
	 * Creates a new ActivityIndicator in the given context.
	 * 
	 * @param context
	 *            The context to create the ActivityIndicator in.
	 * @param attrs
	 *            The attribute set to initialize this ActivityIndicator.
	 */
	public ActivityIndicator(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();

		/*
		 * http://kevindion.com/2011/01/custom-xml-attributes-for-android-widgets
		 * 
		 * I wanted to use this to initialize the current_dot field, however it
		 * doesn't work yet.
		 */
		TypedArray array = getContext().obtainStyledAttributes(attrs,
				R.styleable.ActivityIndicator);
		for (int i = 0; i < array.getIndexCount(); ++i) {
			int attr = array.getIndex(i);
			if (attr == R.styleable.ActivityIndicator_currentActiviy)
				current_dot = array.getInteger(i, 0);
		}
	}

	/**
	 * Initializes the paint objects. It is recommended to store the paint
	 * objects in fields and reusing them than initializing them in the onDraw()
	 * method.
	 */
	private void init() {
		DOTPAINTER.setStyle(Paint.Style.STROKE);
		DOTPAINTER.setStrokeWidth(STROKE_WIDTH);
		DOTPAINTER.setColor(Color.WHITE);
		DOTPAINTER.setDither(true);

		CURRENTPAINTER.setStyle(Paint.Style.FILL);
		CURRENTPAINTER.setStrokeWidth(STROKE_WIDTH);
		CURRENTPAINTER.setColor(Color.WHITE);
		CURRENTPAINTER.setDither(true);
	}

	/**
	 * Lets this indicator show that we are using the given activity.
	 * 
	 * @param activity
	 *            The current activity.
	 */
	public void setCurrentActivity(int activity) {
		if (activity != current_dot) {
			current_dot = Math.abs(activity) % NB_OF_DOTS;
			invalidate();
		}
	}

	/**
	 * Returns the current activity being shown.
	 * 
	 * @return the current activity.
	 */
	public int getCurentActivity() {
		return current_dot;
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
		 * Stores the size of the clip bounds in the given rectangle object and
		 * aborts drawing when the rectangle is empty.
		 */
		if (!canvas.getClipBounds(RECT))
			return;

		int centerX = RECT.centerX();
		int centerY = RECT.centerY();
		int totalWidth = NB_OF_DOTS * (2 * DOT_RADIUS + DOT_SPACING)
				- DOT_SPACING;
		int drawX = centerX - totalWidth / 2 + DOT_RADIUS;

		/*
		 * Iterate over the dots
		 */
		for (int i = 0; i < NB_OF_DOTS; ++i) {
			canvas.drawCircle(drawX, centerY, DOT_RADIUS,
					(i == current_dot) ? CURRENTPAINTER : DOTPAINTER);
			updateRectangle(i, drawX, centerY);
			drawX += 2 * DOT_RADIUS + DOT_SPACING;
		}
		isDirty = false;
	}

	/**
	 * Updates the rectangles for the touch event.
	 * 
	 * @param index
	 * @param drawX
	 * @param drawY
	 */
	private void updateRectangle(int index, int drawX, int drawY) {
		if (isDirty)
			touchRectangles
					.add(new Rect(drawX - DOT_RADIUS, drawY - DOT_RADIUS, drawX
							+ DOT_RADIUS, drawY + DOT_RADIUS));
		else if (touchRectangles.get(index).left != drawX - DOT_RADIUS)
			touchRectangles.set(index, new Rect(drawX - DOT_RADIUS, drawY
					- DOT_RADIUS, drawX + DOT_RADIUS, drawY + DOT_RADIUS));
	}

	/**
	 * Add's the listener.
	 * 
	 * @param listener
	 */
	public void addListener(ActivitySwitchListener listener) {
		if (listener != null)
			listeners.add(listener);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see android.view.View#onTouchEvent(android.view.MotionEvent)
	 */
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		if (event.getAction() == MotionEvent.ACTION_DOWN) {
			for (int i = 0; i < touchRectangles.size(); ++i)
				if (touchRectangles.get(i).contains((int) event.getX(),
						(int) event.getY())) {
					for (ActivitySwitchListener listener : listeners)
						listener.activitySelected(i);
					return true;
				}

			return false;
		} else
			return super.onTouchEvent(event);
	}
}
