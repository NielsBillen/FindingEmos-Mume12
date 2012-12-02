package com.findingemos.felicity.backend;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;
import java.util.Calendar;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.findingemos.felicity.emoticon.Emotion;
import com.findingemos.felicity.friends.Contact;

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
	// Epoch tijd met vrienden en emotie
	private static final String FRIENDS = "EmotionFriends";
	// Activiteiten en hun count
	private static final String ACTIVITIES = "Activities";
	// Geselecteerde contacten en hun count
	private static final String CONTACTSCOUNT = "ContactsCount";
	// alle instellingen
	private static final String SETTINGS = "Settings";
	
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
	private String HISTORY_KEY_EPOCH = "epoch";
	private String HISTORY_KEY_COUNTRY = "country";
	private String HISTORY_KEY_CITY = "city";
	private String HISTORY_KEY_ACTIVITY = "activity";
	private String HISTORY_KEY_EMOTICON = "emoticon_id";
	
	private String FRIENDS_KEY_ID ="_id";
	private String FRIENDS_KEY_NAME = "name";
	private String FRIENDS_KEY_EMOTICON ="emoticon_id";
	private String FRIENDS_KEY_EPOCH = "epoch";
	
	private String ACTIVITIES_KEY_ID = "_id";
	private String ACTIVITIES_KEY_NAME = "name";
	private String ACTIVITIES_KEY_COUNT = "count";
	
	private String CONTACTS_KEY_ID = "_id";
	private String CONTACTS_KEY_NAME = "name";
	private String CONTACTS_KEY_IMAGE = "image";
	private String CONTACTS_KEY_COUNT ="count";
	
	private String SETTINGS_KEY_ID = "_id";
	private String SETTINGS_SETTING = "setting";
	private String SETTINGS_VALUE = "settingsValue";

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
	 * Closes the database.
	 */
	public synchronized void close() {
		if (isClosed)
			return;
		isClosed = true;
		databaseHelper.close();
	}
	
	/////////////////////////////////////////////////////////////////////
	///											HISTORY TABLE 									///
	////////////////////////////////////////////////////////////////////

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
		Cursor count = database.query(true, HISTORY, new String[] { HISTORY_KEY_EMOTICON,
				HISTORY_KEY_DATE, HISTORY_KEY_TIME, HISTORY_KEY_CITY, HISTORY_KEY_COUNTRY,
				HISTORY_KEY_ACTIVITY}, null, null, null, null, null, null);
		if (count != null && count.getCount() > 0) {
			count.moveToFirst();

			while (true) {
				int uniqueId = count.getInt(0);
				String date = count.getString(1);
				String time = count.getString(2);
				String city = count.getString(3);
				String country = count.getString(4);
				String activity = count.getString(5);

				Emotion e = Emotion.getEmoticonByUniqueId(uniqueId);
				Log.i(e.toString(), date + " " + time + " " + city + " " + country +" " + activity);
				
				if (count.isLast())
					break;
				else
					count.moveToNext();
				}
		}
		count.close();
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
			String country, String city, String activity, ArrayList<String> friends, Emotion emotion) {
		if (isClosed) {
			Log.i("EmotionDatabase",
					"@createEmotionEntry: tried to add something to a closed database!");
			return -1;
		}
		long epoch = calendar.getTimeInMillis();
		
		ContentValues entry = new ContentValues();
		entry.put(HISTORY_KEY_DATE, dateString(calendar));
		entry.put(HISTORY_KEY_TIME, timeString(calendar));
		entry.put(HISTORY_KEY_EPOCH, epoch);
		entry.put(HISTORY_KEY_COUNTRY, country);
		entry.put(HISTORY_KEY_CITY, city);
		entry.put(HISTORY_KEY_ACTIVITY, activity);
		entry.put(HISTORY_KEY_EMOTICON, emotion.getUniqueId());
		
		for(int i = 0; i < friends.size(); i++) {
			ContentValues friendsEntry = new ContentValues();
			friendsEntry.put(FRIENDS_KEY_EMOTICON, emotion.getUniqueId());
			friendsEntry.put(FRIENDS_KEY_NAME, friends.get(i));
			friendsEntry.put(FRIENDS_KEY_EPOCH, epoch);
			
			database.insert(FRIENDS, null, friendsEntry);
		}

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
	
	/////////////////////////////////////////////////////////////////////
	///											ACTIVITIES TABLE 									///
	////////////////////////////////////////////////////////////////////
	
	/**
	 * Creates an entry in the ACTIVITIES database and it stores the
	 * activity
	 * 
	 * @param 	activity
	 * 					The new activity to be stored
	 */
	public synchronized long createActivityEntry(String activity) {
		if (isClosed) {
			Log.i("ActivityDatabase",
					"@createActivityEntry: tried to add something to a closed database!");
			return -1;
		}
		ContentValues entry = new ContentValues();
		entry.put(ACTIVITIES_KEY_NAME, activity);
		entry.put(ACTIVITIES_KEY_COUNT, 0);

		return database.insert(ACTIVITIES, null, entry);
	}
	
	/**
	 * Updates the count of an activity by one and stores it in the database.
	 * 
	 * @param 	activity
	 *            		The activity to increase the count of.
	 * @return 	the row which was updated.
	 */
	public synchronized long updateActivityCount(String activity) {
		if (isClosed) {
			Log.i("ActivityDatabase",
					"@updateActivityCount: database is already closed!");
			return -1;
		}

		Cursor cursor = database.query(true, ACTIVITIES, new String[] {
				ACTIVITIES_KEY_ID, ACTIVITIES_KEY_NAME , ACTIVITIES_KEY_COUNT },
				ACTIVITIES_KEY_NAME + "='" + activity +"'", null, null, null,
				null, null);

		int count = 0;
		
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(2);
			ContentValues values = new ContentValues();
			values.put(ACTIVITIES_KEY_ID, cursor.getInt(0));
			values.put(ACTIVITIES_KEY_NAME, activity);
			values.put(ACTIVITIES_KEY_COUNT, count + 1);
			long result = database.update(ACTIVITIES, values, ACTIVITIES_KEY_ID + "="
					+ cursor.getInt(0), null);
			cursor.close();
			return result;
		} else {
			ContentValues values = new ContentValues();
			values.put(ACTIVITIES_KEY_COUNT, count + 1);
			values.put(ACTIVITIES_KEY_NAME, activity);
			long result = database.insert(ACTIVITIES, null, values);
			cursor.close();
			return result;
		}
	}
	
	/**
	 * Returns the amount of time an activity was selected.
	 * 
	 * @param 	activity
	 *            		The activity to get the count from.
	 * @return 	the amount of selections.
	 */
	public synchronized int getCountOfActivity(String activity) {
		if (isClosed) {
			Log.i("ActivityDatabase",
					"@getCountOfActivity: database is already closed!");
			return -1;
		}
		Cursor cursor = database.query(true, ACTIVITIES, new String[] {
				ACTIVITIES_KEY_ID, ACTIVITIES_KEY_NAME, ACTIVITIES_KEY_COUNT },
				ACTIVITIES_KEY_NAME + "='" + activity +"'", null, null, null,
				null, null);
		
		int count = 0;
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(2);
		}

		if (cursor != null)
			cursor.close();

		return count;
	}

	/**
	 * Reads out the statistics for the activities from the "Activities"
	 * database.
	 * 
	 * @return	A sorted Array, based on the count, of the activities. 
	 * 					From most to less popular.
	 */
	public synchronized String[] readActivities() {
		String[] activities = new String[0];
		
		if (isClosed) {
			Log.i("ActivityDatabase",
					"@readActivities: database is already closed!");
			return activities;
		}
		
		Cursor cursor = database.query(true, ACTIVITIES, new String[] {
				ACTIVITIES_KEY_ID, ACTIVITIES_KEY_NAME, ACTIVITIES_KEY_COUNT },
				null, null, null, null, ACTIVITIES_KEY_COUNT  + " DESC", null);
		
		activities = new String[cursor.getCount()];
		cursor.moveToFirst();
		
		if(cursor != null) {
			for(int i = 0; i < cursor.getCount(); i++) {
				activities[i] = cursor.getString(1);
				
				if(i < cursor.getCount() - 1) {
					cursor.moveToNext();
				}
			}
		}
	
		if (cursor != null)
			cursor.close();

		return activities;
	}
	
	
	/////////////////////////////////////////////////////////////////////
	///											CONTACTS TABLE 								///
	////////////////////////////////////////////////////////////////////
	
	/**
	 * Creates an entry in the CONTACTSCOUNT database and it stores the
	 * activity
	 * 
	 * @param 	contactName
	 * 					The new contact to be stored
	 */
	public synchronized long createContactsEntry(Contact contact) {
		if (isClosed) {
			Log.i("ContactDatabase",
					"@createContactEntry: tried to add something to a closed database!");
			return -1;
		}
		
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		contact.getPhoto().compress(Bitmap.CompressFormat.PNG, 100, out);

		ContentValues entry = new ContentValues();
		entry.put(CONTACTS_KEY_NAME, contact.getName());
		entry.put(CONTACTS_KEY_IMAGE, out.toByteArray());
		entry.put(CONTACTS_KEY_COUNT, 0);

		return database.insert(CONTACTSCOUNT, null, entry);
	}
	
	/**
	 * Updates the count of a contact by one and stores it in the database.
	 * 
	 * @param 	contactName
	 *            		The contact to increase the count of.
	 * @return 	the row which was updated.
	 */
	public synchronized long updateContactCount(Contact contact) {
		if (isClosed) {
			Log.i("ContactDatabase",
					"@updateContactCount: database is already closed!");
			return -1;
		}

		Cursor cursor = database.query(true, CONTACTSCOUNT, new String[] {
				CONTACTS_KEY_ID, CONTACTS_KEY_NAME , CONTACTS_KEY_IMAGE, CONTACTS_KEY_COUNT },
				CONTACTS_KEY_NAME + "='" + contact.getName() +"'", null, null, null,
				null, null);

		int count = 0;
		
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(3);
			ContentValues values = new ContentValues();
			values.put(CONTACTS_KEY_ID, cursor.getInt(0));
			values.put(CONTACTS_KEY_NAME, contact.getName());
			values.put(CONTACTS_KEY_IMAGE, cursor.getBlob(2));
			values.put(CONTACTS_KEY_COUNT, count + 1);
			long result = database.update(CONTACTSCOUNT, values, CONTACTS_KEY_ID + "="
					+ cursor.getInt(0), null);
			cursor.close();
			return result;
		} else {
			ContentValues values = new ContentValues();
			values.put(CONTACTS_KEY_COUNT, count + 1);
			values.put(CONTACTS_KEY_NAME, contact.getName());
			
			if(contact.getPhoto() != null) {
				ByteArrayOutputStream out = new ByteArrayOutputStream();
				contact.getPhoto().compress(Bitmap.CompressFormat.PNG, 100, out);
				values.put(CONTACTS_KEY_IMAGE,out.toByteArray());
			}

			long result = database.insert(CONTACTSCOUNT, null, values);
			cursor.close();
			return result;
		}
	}
	
	/**
	 * Returns the amount of time a contact was selected.
	 * 
	 * @param contact
	 *            The contact of which we want the amount of selections.
	 * @return the amount of selections.
	 */
	public synchronized int getCountOfContact(Contact contact) {
		if (isClosed) {
			Log.i("ContactDatabase",
					"@getCountOfContact: database is already closed!");
			return -1;
		}
		Cursor cursor = database.query(true, CONTACTSCOUNT, new String[] {
				CONTACTS_KEY_ID, CONTACTS_KEY_NAME, CONTACTS_KEY_COUNT },
				CONTACTS_KEY_NAME + "='" + contact.getName() +"'", null, null, null,
				null, null);
		
		int count = 0;
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(2);
		}

		if (cursor != null)
			cursor.close();

		return count;
	}
	
	public synchronized boolean firstNameFirst() {
		Cursor cursor = database.query(true, SETTINGS, new String[] {
				SETTINGS_SETTING, SETTINGS_VALUE},
				SETTINGS_SETTING + "='" + "firstname first'" , null, null, null, 
				null, null);
		int count = 0;
		if (cursor != null && cursor.getCount() > 0) {
			cursor.moveToFirst();
			count = cursor.getInt(1);
		}
		
		return count != 0;
	}

	/**
	 * Reads out the statistics for the contacts from the "ContactsCount"
	 * database. 
	 * 
	 * @param	nbOfContactsToRead
	 * 					The number of contacts to return
	 * @return	A sorted Contact Array, based on the count, of the contacts with a length of nbOfContactsToRead. 
	 * 					From most to less popular.
	 */
	public synchronized Contact[] readContacts(int nbOfContactsToRead) {
		Contact[] contacts = new Contact[0];
		
		if (isClosed) {
			Log.i("ContacsDatabase",
					"@readContacts: database is already closed!");
			return contacts;
		}
		
		Cursor cursor = database.query(true, CONTACTSCOUNT, new String[] {
				CONTACTS_KEY_ID, CONTACTS_KEY_NAME, CONTACTS_KEY_IMAGE, CONTACTS_KEY_COUNT },
				null, null, null, null, CONTACTS_KEY_COUNT + " DESC", null);
		
		if(cursor.getCount() < nbOfContactsToRead) {
			contacts = new Contact[cursor.getCount()];
		} else {
			contacts = new Contact[nbOfContactsToRead];
		}
		
		cursor.moveToFirst();
		
		if(cursor != null) {
			for(int i = 0; i < cursor.getCount() && i < nbOfContactsToRead; i++) {
				String name = cursor.getString(1);
				Bitmap photo = null;
				
				byte[] blob = cursor.getBlob(2);
	            if(blob != null) {
	            		photo = BitmapFactory.decodeByteArray(blob, 0, blob.length);
	            }
				
	            Contact contact = new Contact(name, photo);
				contacts[i] = contact;
				
				if(i < cursor.getCount() - 1 && i < nbOfContactsToRead - 1) {
					cursor.moveToNext();
				} else {
					break;
				}
			}
		}
	
		if (cursor != null)
			cursor.close();

		return contacts;
	}
	
	/////////////////////////////////////////////////////////////////////
	///											COUNT TABLE 										///
	////////////////////////////////////////////////////////////////////
	
	/**
	 * Reads out the statistics for the emoticons from the "EmotionCount"
	 * database. The "selection count" of the emoticons will be set to the
	 * stored data.
	 */
	public synchronized void readEmotionCount() {
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
	 * Updates the count of an emotion by one and stores it in the database.
	 * 
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
	
		
	/////////////////////////////////////////////////////////////////////
	///											HELP FUNCTIONS									///
	////////////////////////////////////////////////////////////////////

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
	
	/////////////////////////////////////////////////////////////////////
	///											DATABASE HELPER								///
	////////////////////////////////////////////////////////////////////

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
					+ " text not null, " + HISTORY_KEY_EPOCH
					+ " integer not null, " + HISTORY_KEY_COUNTRY
					+ " text not null, " + HISTORY_KEY_CITY
					+ " text not null, " + HISTORY_KEY_ACTIVITY
					+ " text not null, " + HISTORY_KEY_EMOTICON + " integer);");
			db.execSQL("create table " + COUNT + "(" + COUNT_KEY_ID
					+ " integer primary key, " + COUNT_KEY_COUNT + " integer);");
			db.execSQL("create table " + FRIENDS + "(" + FRIENDS_KEY_ID
					+ " integer primary key, " + FRIENDS_KEY_NAME
					+ " text not null," + FRIENDS_KEY_EMOTICON 
					+ " integer, " + FRIENDS_KEY_EPOCH + " integer not null);");
			db.execSQL("create table " + ACTIVITIES + "(" + ACTIVITIES_KEY_ID
					+ " integer primary key, " + ACTIVITIES_KEY_NAME
					+ " text not null, " + ACTIVITIES_KEY_COUNT + " integer);");
			db.execSQL("create table " + CONTACTSCOUNT + "(" + CONTACTS_KEY_ID
					+ " integer primary key, " + CONTACTS_KEY_NAME
					+ " text not null," + CONTACTS_KEY_IMAGE 
					+ " blob, " + CONTACTS_KEY_COUNT + " integer);");
			db.execSQL("create table " + SETTINGS + "(" + SETTINGS_KEY_ID
					+ " integer primary key, " + SETTINGS_SETTING
					+ "text not null" + SETTINGS_VALUE
					+ "text not null");
			
			db.execSQL("INSERT INTO " + ACTIVITIES + 
					" VALUES (0, 'Work', 0);");
			db.execSQL("INSERT INTO " + ACTIVITIES + 
					" VALUES (1, 'Study', 0);");
			db.execSQL("INSERT INTO " + ACTIVITIES + 
					" VALUES (2, 'Spare time', 0);");
			
			db.execSQL("INSERT INTO " + SETTINGS +
					" VALUES (0, 'firstname first'):");
			
			Log.i("Creating DB", "Done");
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
