
-- This database update adds support for tickets to be handed out to grant
-- specific access to a collection or individual resource, as read-only or
-- read-write.  A table is also added to manage WebDAV binding, in line
-- with http://tools.ietf.org/html/draft-ietf-webdav-bind.

BEGIN;
SELECT check_db_revision(1,2,7);

ALTER TABLE caldav_data ADD COLUMN weak_etag TEXT DEFAULT NULL;

CREATE TABLE access_ticket (
  ticket_id TEXT PRIMARY KEY,
  is_public BOOLEAN,
  privileges BIT(24),
  target_collection_id INT8 NOT NULL REFERENCES collection(collection_id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_resource_id INT8 REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE,
  dav_displayname TEXT,
  expires TIMESTAMP
);


-- At this point we only support binding collections
CREATE TABLE dav_binding (
  bind_id INT8 DEFAULT nextval('dav_id_seq') PRIMARY KEY,
  target_ticket_id TEXT REFERENCES access_ticket(ticket_id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_collection_id INT8 REFERENCES collection(collection_id) ON UPDATE CASCADE ON DELETE CASCADE,
  dav_owner_id INT8 NOT NULL REFERENCES principal(principal_id) ON UPDATE CASCADE ON DELETE CASCADE,
  parent_container TEXT,
  dav_name TEXT,
  dav_displayname TEXT
);


CREATE TABLE collection_mashup (
  mashup_id SERIAL PRIMARY KEY,
  dav_owner_id INT8 NOT NULL REFERENCES principal(principal_id) ON UPDATE CASCADE ON DELETE CASCADE,
  parent_container TEXT,
  dav_name TEXT,
  dav_displayname TEXT
);


CREATE TABLE mashup_member (
  mashup_id INT8 NOT NULL REFERENCES collection_mashup(mashup_id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_ticket_id TEXT REFERENCES access_ticket(ticket_id) ON UPDATE CASCADE ON DELETE CASCADE,
  target_collection_id INT8 REFERENCES collection(collection_id) ON UPDATE CASCADE ON DELETE CASCADE,
  member_colour TEXT
);


CREATE TABLE addressbook_resource (
  dav_id INT8 NOT NULL REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE PRIMARY KEY,
  version TEXT,
  uid TEXT,
  nickname TEXT,
  fn TEXT, -- fullname
  n TEXT, -- Name Surname;First names
  note TEXT,
  org TEXT,
  url TEXT
);

CREATE TABLE addressbook_address_adr (
  dav_id INT8 NOT NULL REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE,
  type TEXT,
  adr TEXT,
  property TEXT -- The full text of the property
);

CREATE TABLE addressbook_address_tel (
  dav_id INT8 NOT NULL REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE,
  type TEXT,
  tel TEXT,
  property TEXT -- The full text of the property
);

CREATE TABLE addressbook_address_email (
  dav_id INT8 NOT NULL REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE,
  type TEXT,
  email TEXT,
  property TEXT -- The full text of the property
);


CREATE TABLE calendar_alarm (
  dav_id INT8 NOT NULL REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE,
  action TEXT,
  trigger TEXT,
  summary TEXT,
  description TEXT,
  component TEXT -- The full text of the component
);

CREATE TABLE calendar_attendee (
  dav_id INT8 NOT NULL REFERENCES caldav_data(dav_id) ON UPDATE CASCADE ON DELETE CASCADE,
  status TEXT,
  partstat TEXT,
  cn TEXT,
  attendee TEXT,
  role TEXT,
  rsvp BOOLEAN,
  property TEXT -- The full text of the property
);

SELECT new_db_revision(1,2,8, 'Août' );

COMMIT;
ROLLBACK;
