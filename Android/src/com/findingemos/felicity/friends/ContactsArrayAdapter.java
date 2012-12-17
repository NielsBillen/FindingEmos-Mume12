package com.findingemos.felicity.friends;

import java.util.List;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.findingemos.felicity.R;

public class ContactsArrayAdapter extends ArrayAdapter<Contact> {

	public ContactsArrayAdapter(Context context, int textViewResourceId,
			List<Contact> contacts) {
		super(context, textViewResourceId, contacts);
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		if (convertView == null) {
			LayoutInflater inflater = (LayoutInflater) this.getContext()
					.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			convertView = inflater.inflate(R.layout.contacts_view_row, parent,
					false);
		}

		Contact contact = getItem(position);

		if (contact.isSelected()) {
			convertView.setBackgroundColor(R.color.LightBlue);
		} else {
			convertView.setBackgroundResource(R.drawable.emotionbackground);
		}

		TextView contactName = (TextView) convertView
				.findViewById(R.id.contacts_view_contact_name);

		SharedPreferences settings = PreferenceManager.getDefaultSharedPreferences(getContext());
		boolean firstnameFirst = settings.getBoolean("firstname enabled", true);

		if (firstnameFirst)
			contactName.setText(contact.getName());
		else
			contactName.setText(contact.getLastName() + " "
					+ contact.getFirstName());

		ImageView contactPhoto = (ImageView) convertView
				.findViewById(R.id.contacts_view_contact_image);
		if (contact.getPhoto() != null) {
			contactPhoto.setImageBitmap(contact.getPhoto());
		} else {
			contactPhoto.setImageResource(R.drawable.default_avatar);
		}

		return convertView;
	}
}
