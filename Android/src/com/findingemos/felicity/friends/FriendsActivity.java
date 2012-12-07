package com.findingemos.felicity.friends;

import java.io.ByteArrayInputStream;
import java.util.ArrayList;
import java.util.List;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentUris;
import android.content.Intent;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.provider.BaseColumns;
import android.provider.ContactsContract;
import android.provider.ContactsContract.Contacts;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.findingemos.felicity.R;
import com.findingemos.felicity.backend.EmotionDatabase;
import com.findingemos.felicity.emoticon.EmotionActivity;

/**
 * Deze activiteit vraagt de gebruiker met welke vrienden hij momenteel is.
 * De vrienden waaruit hij keuze heeft, zijn zijn contactpersonen in de gsm.
 * 
 * @author Stijn
 *
 */
public class FriendsActivity extends Activity {
	
	// Hoeveel favorieten er bovenaan het scherm staan.
	private static final int nbOfFavorites = 3;

	// Variable die de database bijhoudt.
	public static EmotionDatabase DATABASE = EmotionActivity.DATABASE;
	
	// Variable die de geselecteerde contactpersonen van de gebruiker bijhoudt.
	private ArrayList<Contact> selectedContacts = new ArrayList<Contact>();

	// Variable die de tekstview van het aantal vrienden geselecteerd bijhoudt.
	private TextView nbOfFriendsSelected;

    @SuppressLint("NewApi")
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.contacts_activity);
        setTitle("Who are you with?");
        
        // Haal de contacten op.
        List<Contact> contactList = loadContacts();
        Contact[] favorites = initFavorites();
        contactList = deleteFavoritesOutContacts(contactList, favorites);
        
        ContactsArrayAdapter adapter = new ContactsArrayAdapter(getApplicationContext(), R.layout.contacts_view_row, contactList);
       
        initContacsListView(adapter);
        initOKButton();
        
        nbOfFriendsSelected = (TextView) this.findViewById(R.id.contacts_list_friends_selected);
    }
    
    /**
     * Deze methode verwijdert de meegegeven favorieten uit de meegegeven contacten.
     * 
     * @param 	contactList
     * 					De de meegegeven contactlijst.
     * @param 	favorites
     * 					De favorieten.
     * @return	De contactlijst zonder de favorieten.
     */
    private List<Contact> deleteFavoritesOutContacts(List<Contact> contactList, Contact[] favorites) {
    		List<Contact> remainingContacts = new ArrayList<Contact>();
    	
    		for(Contact contact: contactList) {
    			boolean isFavorite = false;
    			
    			for(Contact favorite: favorites) {
    				if(contact.equals(favorite)) {
    					isFavorite = true;
    				}
    			}
    			
    			if(!isFavorite) {
    				remainingContacts.add(contact);
    			}
    		}

		return remainingContacts;
	}

	/**
     * Initialiseer de vriendenlijst op het scherm.
     * 
     * @param 	adapter
     */
	private void initContacsListView(ContactsArrayAdapter adapter) {
		ListView lv = (ListView) this.findViewById(R.id.contacts_view_list);
        lv.setAdapter(adapter);
        setListItemClickListeners(lv);
	}

	/**
	 * Initialiseer de actie die OK-button moet doen.
	 */
	private void initOKButton() {
		Button button = (Button) this.findViewById(R.id.contacts_list_button_ok);
        setOKButtonClickListeners(button);
	}

	/**
	 * Initialiseer de favorieten bovenaan op het scherm.
	 */
	private Contact[] initFavorites() {
		ImageView firstFav = (ImageView) this.findViewById(R.id.contacts_view_first_contact);
		ImageView secondFav = (ImageView) this.findViewById(R.id.contacts_view_second_contact);
		ImageView thirdFav = (ImageView) this.findViewById(R.id.contacts_view_third_contact);

		ImageView[] imageViews = {firstFav, secondFav, thirdFav};

		// Haal de favoriten op uit de database.
        DATABASE.open();
		Contact[] contacts = DATABASE.readContacts(nbOfFavorites);
		
		// Initialiseer de imageviews op het scherm.
		for(int i = 0; i < contacts.length && i < nbOfFavorites; i++) {
			imageViews[i].setTag(contacts[i]);

			Bitmap photo = contacts[i].getPhoto();
			if(photo != null) {
				imageViews[i].setImageBitmap(photo);
			} else {
				imageViews[i].setImageResource(R.drawable.default_avatar);
			}
			setFavoritesClickListeners(imageViews[i]);
		}
		Log.i("length", contacts.length + "");
		return contacts;
	}
    
	/**
	 * Laad de contacten van de gebruiker in.
	 * 
	 * @return	Een lijst met daarin alle contactpersonen uit de gsm van de gebruker.
	 * 					Enkel contacten met een telefoonnummer worden hierin opgenomen.
	 */
    private List<Contact> loadContacts(){
    		List<Contact> contacts = new ArrayList<Contact>();

        Uri uri = ContactsContract.Contacts.CONTENT_URI;
        String[] projection    = new String[] {ContactsContract.Contacts.DISPLAY_NAME,
        		BaseColumns._ID, ContactsContract.Contacts.HAS_PHONE_NUMBER};
        Cursor people = getContentResolver().query(uri, projection, null, null, ContactsContract.Contacts.DISPLAY_NAME);

        int indexName = people.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME);
        int indexId = people.getColumnIndex(BaseColumns._ID);
        int indexHasNumber = people.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER);

        while (people.moveToNext()) {
            String hasNumber = people.getString(indexHasNumber);
            if(hasNumber.equals("1")) {
            		String name   = people.getString(indexName);
                String id = people.getString(indexId);
                Bitmap photo = getByteContactPhoto(id);
                Contact contact = new Contact(name, photo);
                contacts.add(contact);
            }
        } 

        return contacts;
   }
    
    /**
     * Haalt de foto van de contactpersoon op.
     * 
     * @param 	contactId
     * 					Het id van de contactpersoon.
     * @return	Een bitmap met hierin de foto van de gebruiker.
     */
    // Van internet - StackOverflow
    private Bitmap getByteContactPhoto(String contactId) {
    		Uri contactUri = ContentUris.withAppendedId(Contacts.CONTENT_URI, Long.parseLong(contactId));
    		Uri photoUri = Uri.withAppendedPath(contactUri, Contacts.Photo.CONTENT_DIRECTORY);
    		Cursor cursor = getContentResolver().query(photoUri, new String[] {Contacts.Photo.DATA15}, null, null, null);
    		
    		if (cursor == null) {
    			return null;
    		}
    		
    		try {
    			if (cursor.moveToFirst()) {
    				byte[] data = cursor.getBlob(0);
    				if (data != null) {
    					return BitmapFactory.decodeStream( new ByteArrayInputStream(data));
    				}
    			}
    		} finally {
    			cursor.close();
    		}

    		return null;
    	}
    
    /**
     * Methode die een actie koppelt aan de items uit de vriendenlijst.
     * 
     * @param 	lv
     * 					De vriendenlijst.
     */
    private void setListItemClickListeners(final ListView lv) {
    		lv.setOnItemClickListener(new OnItemClickListener() {

    			@Override
    			public void onItemClick(AdapterView<?> parent, View v, int position, long id) {

    				Contact contact = (Contact) lv.getItemAtPosition(position);
    				clickedOnContactInView(v, contact);
    			}
    		});
    }
    
    /**
     * Methode die een actie koppelt aan de favorieten-imageviews.
     * 
     * @param 	imageView
     * 					De view met hierin een favoriet.
     */
    private void setFavoritesClickListeners(final ImageView imageView) {	
    		imageView.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					Contact contact = (Contact) imageView.getTag();
					clickedOnContactInView(v, contact);
				}
			});
    }
    
    /**
     * Methode die aangeeft wat er moet gebeuren wanneer er op een contactview wordt geklikt.
     * 
     * @param 	v
     * 					De desbetreffende view
     * @param 	contact
     * 					Het desbetreffende contact
     */
	@SuppressWarnings("deprecation")
	private void clickedOnContactInView(View v, Contact contact) {
		contact.setSelected(!contact.isSelected());
		Log.i("selected", "" + contact.isSelected());
		
		if(contact.isSelected()) {
			v.setBackgroundColor(R.color.LightBlue);
			selectedContacts.add(contact);
			setNbOfFriendsSelected();
		} else {
			if(v instanceof ImageView) {
				v.setBackgroundDrawable(null);
			} else {
				v.setBackgroundResource(R.drawable.emotionbackground);
			}
			selectedContacts.remove(contact);
			setNbOfFriendsSelected();
		}
    }

	/**
	 * Methode die de tekst van de nbOfFriendsSelected textview update.
	 */
    private void setNbOfFriendsSelected() {
    		int size = selectedContacts.size();
    		if(size == 1) {
    			nbOfFriendsSelected.setText(selectedContacts.size() + " friend selected");
    		} else {
    			nbOfFriendsSelected.setText(selectedContacts.size() + " friends selected");
    		}
    }
    
    /**
     * Methode die een actie aan de OK-button koppelt.
     * 
     * @param 	button
     * 					De ok-button.
     */
    private void setOKButtonClickListeners(final Button button) {
    		button.setOnClickListener(new OnClickListener() {
				
				@Override
				public void onClick(View v) {
					ArrayList<String> selectedContactsNames = new ArrayList<String>();
					
					for(int i = 0; i < selectedContacts.size(); i++) {
						Log.i("SelectedContact", selectedContacts.get(i).getName());
						DATABASE.updateContactCount(selectedContacts.get(i));
						selectedContactsNames.add(selectedContacts.get(i).getName());
					}
					
					Intent result = new Intent();
					result.putExtra("friends", selectedContactsNames);
					setResult(RESULT_OK, result);
					EmotionActivity.doingStarted = false;
					finish();
				}
			});
    }
}
