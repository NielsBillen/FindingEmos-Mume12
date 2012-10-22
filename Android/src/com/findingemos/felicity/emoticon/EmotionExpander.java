package com.findingemos.felicity.emoticon;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Shader.TileMode;
import android.util.AttributeSet;
import android.view.View;

/**
 * A bar for expanding the scroll bar with the emotion.
 * 
 * @author Niels
 * @version 0.1
 */
public class EmotionExpander extends View {
	// The paint object for drawing the expander.
	private final Paint EXPANDER_GRADIENT = new Paint(Paint.ANTI_ALIAS_FLAG);

	// The paint ofbject for drawing the black circles.
	private final Paint EXPANDER_CIRCLES = new Paint(Paint.ANTI_ALIAS_FLAG);

	// The height of the expander
	private final int HEIGHT = 16;

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
	 * Creates the expander in the given context.
	 * 
	 * @param context
	 *            The context to create the expander in.
	 */
	public EmotionExpander(Context context) {
		super(context);
		init();
	}

	/**
	 * Creates the expander in the given context.
	 * 
	 * @param context
	 *            The context to create the expander in.
	 * @param attrs
	 *            Attributes for the creation.
	 */
	public EmotionExpander(Context context, AttributeSet attrs) {
		super(context, attrs);
		init();
	}

	/**
	 * Initializes the drawing resources.
	 */
	private void init() {
		LinearGradient gradient = new LinearGradient(0, 0, 0, HEIGHT,
				Color.GRAY, Color.DKGRAY, TileMode.CLAMP);
		EXPANDER_GRADIENT.setShader(gradient);
		EXPANDER_GRADIENT.setStyle(Style.FILL);

		EXPANDER_CIRCLES.setColor(Color.BLACK);
		EXPANDER_CIRCLES.setStyle(Style.FILL);
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
		int centerX = rect.centerX();
		int dotRadius = 5;
		int width = (rect.width() * 3) / 4;

		RectF rectangle = new RectF(centerX - width / 2, rect.top, centerX
				+ width / 2, rect.top + rect.height() * 10);
		canvas.drawRoundRect(rectangle, 2 * rect.height(), 2 * rect.height(),
				EXPANDER_GRADIENT);

		// canvas.drawRect(centerX - WIDTH / 2, rect.top + 8, centerX + WIDTH /
		// 2,
		// rect.bottom, EXPANDER_PAINTER);
		canvas.drawCircle(centerX, rect.height() / 2, dotRadius,
				EXPANDER_CIRCLES);
		canvas.drawCircle(centerX - width / 4, rect.height() / 2, dotRadius,
				EXPANDER_CIRCLES);
		canvas.drawCircle(centerX + width / 4, rect.height() / 2, dotRadius,
				EXPANDER_CIRCLES);
	}
}
