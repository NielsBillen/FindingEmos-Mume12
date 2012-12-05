package com.findingemos.felicity.util;

import android.graphics.Bitmap;

/**
 * This is a helper class to scale bitmap images.
 * 
 * @author Niels
 * @version 0.1
 */
public class ImageScaler {
	/**
	 * This method will scale the given bitmap image so that it will fit just
	 * inside a canvas with the given width and height.<br>
	 * <br>
	 * The aspect ratio of the image will be retained.
	 * 
	 * @param bitmap
	 *            The bitmap image to scale.
	 * @param width
	 *            The width of the canvas in which the image should fit.
	 * @param height
	 *            The height of the canvas in which the image should fit.
	 * @throws IllegalArgumentException
	 *             When the bitmap is zero.
	 * @throws IllegalArgumentException
	 *             When the width or height is less than or equal to zero.
	 * @return the scaled bitmap image.
	 */
	public static Bitmap convert(Bitmap bitmap, int width, int height)
			throws IllegalArgumentException {
		if (width <= 0)
			throw new IllegalArgumentException(
					"The width is less or equal to zero!");
		if (height <= 0)
			throw new IllegalArgumentException(
					"The height is less or equal to zero!");
		if (bitmap == null)
			throw new IllegalArgumentException("The given bitmap is null!");
		int imageWidth = bitmap.getWidth();
		int imageHeight = bitmap.getHeight();

		double imageRatio = (double) imageWidth / (double) imageHeight;
		double canvasRatio = (double) width / (double) height;

		int finalWidth;
		int finalHeight;

		if (imageRatio > canvasRatio) {
			/*
			 * The image is wider than the canvas. Therefore we will make sure
			 * that the width of the image equals that of the canvas. The height
			 * will be in the bounds automatically.
			 */
			finalWidth = width;
			finalHeight = (int) (width / imageRatio);
		} else {
			/*
			 * The image has to be fit by the height.
			 */
			finalHeight = height;
			finalWidth = (int) (height * imageRatio);
		}

		return Bitmap.createScaledBitmap(bitmap, finalWidth, finalHeight, true);
	}
}
