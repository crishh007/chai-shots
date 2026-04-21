# ChaiShots Database Schema

This document describes the database structure used in the ChaiShots application.

---

 1. Users Collection

Stores user account information.

Fields:

_id (ObjectId)

name (String)

email (String)

password (String)

profileImage (String)

role (String) — user / admin / creator

subscriptionStatus (Boolean)

createdAt (Date)

updatedAt (Date)









2. Series Collection

Stores information about shows or short series.

Fields:

_id (ObjectId)

title (String)

description (String)

posterUrl (String)

genre (String)

language (String)

totalEpisodes (Number)

createdAt (Date)

updatedAt (Date)








3. Episodes Collection

Stores episodes that belong to a series.

Fields:

_id (ObjectId)

seriesId (ObjectId → Series)

episodeNumber (Number)

title (String)

videoUrl (String)

thumbnailUrl (String)

duration (Number)

isPremium (Boolean)

views (Number)

createdAt (Date)

updatedAt (Date)







4. WatchHistory Collection

Tracks the progress of users watching episodes.

Fields:

_id (ObjectId)

userId (ObjectId → User)

episodeId (ObjectId → Episode)

progress (Number)

lastWatchedAt (Date)






5. Subscriptions Collection

Stores subscription details of users.

Fields:

_id (ObjectId)

userId (ObjectId → User)

planType (String)

startDate (Date)

expiryDate (Date)

status (String)

createdAt (Date)







6. Claps Collection

Stores appreciation messages or tips sent by users to creators.

Fields:

_id (ObjectId)

userId (ObjectId → User)

episodeId (ObjectId → Episode)

message (String)

amount (Number)

createdAt (Date)






7. Notifications Collection

Stores notifications for users.

Fields:

_id (ObjectId)

userId (ObjectId → User)

type (String)

referenceId (ObjectId)

message (String)

isRead (Boolean)

createdAt (Date)


Relationships

User → subscribes → Subscription
User → watches → Episode
User → claps → Episode

Series → contains → Episodes
Episode → belongs to → Series