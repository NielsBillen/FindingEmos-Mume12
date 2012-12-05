package com.findingemos.felicity.backend;

import java.util.Calendar;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

import com.findingemos.felicity.emoticon.Emotion;

/**
 * Database which stores all the data about emotions.<br>
 * <br>
 * This database stores the history of usage of each emotion to sort them and
 * find the most used emotions. It also stores when an emotion was selected/in
 * which city/country, etc.<br>
 * <br>
 * This is done in an sql database with two tables. The first is called
 * "EmotionCount", which stores the usage history and the second is called
 * "EmotionDatabase" which is used to store the date,time, country, city etc.<br>
 * 
 * @author Niels
 * @version 0.1
 */
public class EmotionDatabase {
	// Context to create the database in.
	private final Context context;
	// Name of the database with the time/date/location
	private static final String HISTORY = "EmotionDatabase";
	// Name of the database with the counts for the emoticons.
	private static final String COUNT = "EmotionCount";
	// The database itself
	private SQLiteDatabase database;
	// A helper class to initialize the database (see Notepad example)
	private EmotionDatabaseHelper databaseHelper;
	// Whether the database is closed
	private boolean isClosed = true;

	/*
	 * These are keys for fields in the database.
	 */
	private String COUNT_KEY_ID = "_id";
	private String COUNT_KEY_COUNT = "count";
	private String HISTORY_KEY_ID = "_id";
	private String HISTORY_KEY_DATE = "date";
	private String HISTORY_KEY_TIME = "time";
	private String HISTORY_KEY_COUNTRY = "country";
	private String HISTORY_KEY_CITY = "city";
	private String HISTORY_KEY_EMOTICON = "emoticon_id";

	/**
	 * Creates a new database for the given context.
	 * 
	 * @param context
	 *            The context to create the database for.
	 * @throws IllegalArgumentException
	 *             When the given context is null.
	 */
	public EmotionDatabase(Context context) throws IllegalArgumentException {
		if (context == null)
			throw new IllegalArgumentException("The given context is null!");
		this.context = context;
	}

	/**
	 * Opens the database.
	 */
	public synchronized void open() {
		if (isClosed) {
			databaseHelper = new EmotionDatabaseHelper(context);
			database = databaseHelper.getWritableDatabase();
			isClosed = false;
		}
	}

	/**
	 * Reads out the statistics for the emoticons from the "EmotionCount"
	 * database. The "selection count" of the emoticons will be set to the
	 * stored data.
	 */
	public synchronized void readEmotionDatabase() {
		if (isClosed) {
			Log.i("EmotionDatabase",
					"@readEmotionDatabase: tried to read from closed database.");
			return;
		}
		Cursor count = database.query(true, COUNT, new String[] { COUNT_KEY_ID,
				COUNT_KEY_COUNT }, null, null, null, null, null, null);
		if (count != null && count.getCount() > 0) {
			count.moveToFirst();

			while (true) {
				for (int i = 0; i < count.getColumnCount(); ++i) {
					int uniqueId = count.getInt(0);
					int value = count.getInt(1);

					Emotion e = Emotion.getEmoticonByUniqueId(uniqueId);
					e.setSelectionCount(value);
				}
				if (count.isLast())
					break;
				else
					count.moveToNext();
			}
		}
		count.close();
	}

	/**
	 * Closes the database.
	 */
	public synchronized void close() {
		if (isClosed)
			return;
		isClosed = true;
		databaseHelper.close();
	}

	/**
	 * Creates an entry in the database and it stores the
	 * data/time/location/city
	 * 
	 * @param calendar
	 *            Calendar object for time and date (Date is deprecated)
	 * @param country
	 *            The country we are in.
	 * @param city
	 *            The city we are in.
	 * @param emotion
	 *            The emotion which was selected.
	 */
	public synchronized long createEmotionEntry(Calendar calendar,
			String country, String city, Emotion emotion) {
		if (isClosed) {
			Log.i("EmotionDatabase",
					"@createEmotionEntry: tried to add something to a closed database!");
			return -1;
		}
		ContentValues entry = new ContentValues();
		entry.put(HISTORY_KEY_DATE, dateString(calendar));
		entry.put(HISTORY_KEY_TIME, timeString(calendar));
		entry.put(HISTORY_KEY_COUNTRY, country);
		entry.put(HISTORY_KEY_CITY, city);
		entry.put(HISTORY_KEY_EMOTICON, emotion.getUniqueId());

		return database.insert(HISTORY, null, entry);
	}

	/**
	 * Deletes the history entry at the given row.
	 * 
	 * @param rowId
	 * @return
	 */
	public synchronized boolean deleteEmotionEntry(long rowId) {
		if (isClosed) {
			Log.i("EmotionDatabase",
					"@deleteEmotionEntry: tried to remove something to a closed database!");
			return false;
		}
		return database.delete(HISTORY, "_id = " + rowId, null) > 0;
	}

	/**
	 * Updates the count of an emotion by one and stores it in the database.<br>
	 * <br>
	 * Note, this only affects data in the database. This code will not increase
	 * the selectionCount in the passed emotion!
	 * 
	 * @param emotion
	 *            The emotion to increase the count of.
	 * @return the row which was updated.
	 */
	public synchronized long updateEmotionCount(Emotion emotion) {
		if (isClosed) {
			Log.i("EmotionDatabase",
					"@updateEmotionCount: database is already closed!");
			return -1;
		}

		Cursor cursor = database.query(true, COUNT, new String[] {
				COUNT_KEY_ID, COUNT_KEY_COUNT },
				COUNT_KEY_ID + "=" + emotion.getUniqueId(), null, null, null,
				null, null);
		int count = 0;
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(1);
			ContentValues values = new ContentValues();
			values.put(COUNT_KEY_ID, emotion.getUniqueId());
			values.put(COUNT_KEY_COUNT, count + 1);
			long result = database.update(COUNT, values, COUNT_KEY_ID + "="
					+ emotion.getUniqueId(), null);
			cursor.close();
			return result;
		} else {
			ContentValues values = new ContentValues();
			values.put(COUNT_KEY_ID, emotion.getUniqueId());
			values.put(COUNT_KEY_COUNT, count + 1);
			long result = database.insert(COUNT, null, values);
			cursor.close();
			return result;
		}
	}

	/**
	 * Returns the amount of time an emotion was selected.
	 * 
	 * @param emoticon
	 *            The emotion of which we want the amount of selections.
	 * @return the amount of selections.
	 */
	public synchronized int getCountOfEmoticon(Emotion emoticon) {
		if (isClosed) {
			Log.i("EmotionDatabase",
					"@getCountOfEmotion: database is already closed!");
			return -1;
		}
		Cursor cursor = database.query(true, COUNT, new String[] {
				COUNT_KEY_ID, COUNT_KEY_COUNT },
				COUNT_KEY_ID + "=" + emoticon.getUniqueId(), null, null, null,
				null, null);

		int count = 0;
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(1);
		}

		if (cursor != null)
			cursor.close();

		return count;
	}

	/**
	 * Returns a formatted date string from the calendar object.<br>
	 * <br>
	 * The string will be of the form DD/MM/YYYY
	 * 
	 * @param calendar
	 *            Calendar containing time and day.
	 * @return a formatted date string from the calendar object.
	 */
	private String dateString(Calendar calendar) {
		int day = calendar.get(Calendar.DAY_OF_MONTH);
		int month = calendar.get(Calendar.MONTH);
		int year = calendar.get(Calendar.YEAR);

		String dayStr = day < 10 ? "0" + day : "" + day;
		String monthStr = month < 10 ? "0" + month : "" + month;
		String yearStr;

		switch (("" + year).length()) {
		case 0:
			yearStr = "0000";
			break;
		case 1:
			yearStr = "000" + year;
			break;
		case 2:
			yearStr = "00" + year;
			break;
		case 3:
			yearStr = "0" + year;
			break;
		default:
			yearStr = "" + year;
			break;
		}
		return dayStr + "/" + monthStr + "/" + yearStr;
	}

	/**
	 * Returns a formatted time string from the calendar object.<br>
	 * <br>
	 * The string will be of the form hh-mm-ss
	 * 
	 * @param calendar
	 *            Calendar containing time and day.
	 * @return a formatted time string from the calendar object.
	 */
	private String timeString(Calendar calendar) {
		int hour = calendar.get(Calendar.HOUR_OF_DAY);
		int minute = calendar.get(Calendar.MINUTE);
		int second = calendar.get(Calendar.SECOND);
		String hourStr = hour < 10 ? "0" + hour : "" + hour;
		String minuteStr = minute < 10 ? "0" + minute : "" + minute;
		String secondStr = second < 10 ? "0" + second : "" + second;
		return hourStr + "-" + minuteStr + "-" + secondStr;

	}

	/**
	 * 
	 * @author Niels
	 * @version 0.1
	 */
	public class EmotionDatabaseHelper extends SQLiteOpenHelper {
		/**
		 * 
		 * @param context
		 */
		public EmotionDatabaseHelper(Context context) {
			super(context, HISTORY, null, DatabaseVersionCodes.EMOTION_CURRENT);
		}

		/*
		 * (non-Javadoc)
		 * 
		 * @see
		 * android.database.sqlite.SQLiteOpenHelper#onCreate(android.database
		 * .sqlite.SQLiteDatabase)
		 */
		@Override
		public void onCreate(SQLiteDatabase db) {
			db.execSQL("create table " + HISTORY + "(" + HISTORY_KEY_ID
					+ " integer primary key autoincrement, " + HISTORY_KEY_DATE
					+ " text not null, " + HISTORY_KEY_TIME
					+ " text not null, " + HISTORY_KEY_COUNTRY
					+ " text not null, " + HISTORY_KEY_CITY
					+ " text not null, " + HISTORY_KEY_EMOTICON + " integer);");
			db.execSQL("create table " + COUNT + "(" + COUNT_KEY_ID
					+ " integer primary key, " + COUNT_KEY_COUNT + " integer);");
		}

		/*
		 * (non-Javadoc)
		 * 
		 * @see
		 * android.database.sqlite.SQLiteOpenHelper#onUpgrade(android.database
		 * .sqlite.SQLiteDatabase, int, int)
		 */
		@Override
		public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
			try {
				db = DatabaseVersionCodes.performUpdate(db, oldVersion,
						newVersion);
				Log.i("EmotionDatabase",
						"Succesfully performed update from version "
								+ oldVersion + " to " + newVersion);
			} catch (IllegalArgumentException e) {
				Log.i("EmotionDatabase",
						"An error occured while upgrading the database.. "
								+ "all data has been deleted");
				db.execSQL("DROP TABLE IF EXISTS " + HISTORY);
				onCreate(db);
			}
		}
	}

	/**
	 * 
	 */
	public void printOut() {
		if (isClosed) {
			Log.i("EmotionDatabase", "@printOut: database is already closed!");
			return;
		}
		System.out.println("---History---");
		Cursor cursor = database.query(true, HISTORY, new String[] {
				HISTORY_KEY_ID, HISTORY_KEY_DATE, HISTORY_KEY_TIME,
				HISTORY_KEY_COUNTRY, HISTORY_KEY_CITY, HISTORY_KEY_EMOTICON },
				null, null, null, null, null, null);

		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();

			do {
				for (int i = 0; i < cursor.getColumnCount(); ++i) {
					System.out.print(cursor.getString(i));
					if (i != cursor.getColumnCount() - 1)
						System.out.print("€");
				}
				System.out.println();
				// if (cursor.isLast())
				// break;
				// else
				// cursor.moveToNext();
			} while (cursor.moveToNext());
		}

		Cursor count = database.query(true, COUNT, new String[] { COUNT_KEY_ID,
				COUNT_KEY_COUNT }, null, null, null, null, null, null);

		System.out.println("---Counts---");
		System.out.println("NbOfEntries: " + count.getCount());
		if (count != null && count.getCount() > 0) {
			count.moveToFirst();

			do {
				System.out.print(Emotion.getEmoticonByUniqueId(count.getInt(0))
						.getName() + "-");
				for (int i = 1; i < count.getColumnCount(); ++i) {
					System.out.print(count.getString(i));
					if (i != count.getColumnCount() - 1)
						System.out.print("-");
				}
				System.out.println();

				// if (count.isLast())
				// break;
				// else
				// count.moveToNext();
			} while (count.moveToNext());
		}
	}
}
