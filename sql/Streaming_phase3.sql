Phase III: Stored Procedures [v0] [March 12th, 2026]

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set session SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'media_streaming_service';
use media_streaming_service;

-- -------------------
-- Stored Procedures
-- -------------------

-- -----------------------------------------------------------------------------
-- [1] renew_subscription()
-- -----------------------------------------------------------------------------
/* This SP extends the end_date of an existing subscription for a listener to a later date. 
Update the subscription's end date to the new end date for the given listener.
Ensure that the listener ID and the new end date are both non-null and that the listener 
exists with a current subscription. Ensure the end date is strictly after the current date 
and strictly later than the subscription's current end date. 
HINT: CURDATE() can be useful here. Also, in a family plan, anyone within the family 
is allowed to renew the subscription.*/
-- -----------------------------------------------------------------------------
drop procedure if exists renew_subscription;
delimiter //
create procedure renew_subscription(
	in ip_listenerID varchar(20), 
    in ip_new_date date
)
sp_main: begin
	DEClARE ip_current_end DATE DEFAULT NULL;
    DECLARE ip_subscription_id VARCHAR(20) DEFAULT NULL;
    
    IF ip_listenerID IS NULL OR ip_new_date IS NULL THEN
        LEAVE sp_main;
	END IF;
    
    #accountID exists in User table
    IF ip_listenerID NOT IN (SELECT accountID FROM user) THEN
		LEAVE sp_main;
	END IF;
    
    #check the new date is after the current end date
    IF ip_new_date <= CURDATE() THEN #CURDATE retrieves the current date for the comparison
        LEAVE sp_main;
	END IF;
    
SELECT 
    s.subscriptionID, s.end_date
INTO ip_subscription_id , ip_current_end FROM
    subscription s
        JOIN
    listener l ON s.subscriptionID = l.subscription
WHERE
    l.accountID = ip_listenerID;
    
    #We make sure the listener exists
    IF ip_subscription_id IS NULL THEN
        LEAVE sp_main;
	END IF;
    
    #ensure end date is actually later
    IF ip_new_date <= ip_current_end THEN
        LEAVE sp_main;
	END IF;
    
UPDATE subscription 
SET 
    end_date = ip_new_date
WHERE
    subscriptionID = ip_subscription_id;

end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [2] duplicate_playlist()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a copy of an existing playlist under a new playlist ID.
Ensure that both the input playlist ID and the new playlist ID are non-null, 
that the input playlist exists, and that it currently contains at least one song. 
Also, make sure the new playlist ID does not currently exist in the database.
Insert a new row into the playlist table with the new playlist ID, 
setting its name to 'Copy of ' concatenated with the original playlist's name and using the 
same listener as the owner. For all songs in the original playlist, it inserts each song into 
makes_up for the new playlist so that the copy has the same song contents.
HINT: CONCAT() can be useful here. */
-- -----------------------------------------------------------------------------
drop procedure if exists duplicate_playlist;
delimiter //
create procedure duplicate_playlist(
    in ip_playlistID varchar(20),
    in ip_new_playlistID varchar(20)
)
sp_main: begin
	#Declare variables
    DECLARE old_name VARCHAR(100) DEFAULT NULL;
    DECLARE v_listenerID VARCHAR(20) DEFAULT NULL;
    
	#ensure both input playlist ID and new playlistID are not null
	IF ip_playlistID IS NULL OR ip_new_playlistID IS NULL THEN
		LEAVE sp_main;
	END IF;
    
SELECT 
    name, listenerID
INTO old_name , v_listenerID FROM
    playlist
WHERE
    playlistID = ip_playlistID;
    
    IF old_name IS NULL THEN
		LEAVE sp_main;
	END IF;
    
    #ensure input playlist exists
    IF ip_playlistID NOT IN (SELECT playlistID FROM playlist) THEN
		LEAVE sp_main;
	END IF;
    
    #Ensure the playlist contains at least one song
    IF ip_playlistID NOT IN (SELECT playlistID FROM makes_up) THEN
		LEAVE sp_main;
	END IF;
    
    #make sure the new playlist ID does not currently exist in the database
    IF ip_new_playlistID IN (SELECT playlistID FROM playlist) THEN
		LEAVE sp_main;
	END IF;
    
    #Insert into playlist
    INSERT INTO playlist (playlistID, name, listenerID)
    VALUES (ip_new_playlistID, CONCAT('Copy of ', old_name), v_listenerID);
    
    #insert into Makes_up
    INSERT INTO makes_up (songID, playlistID, track_order) 
    SELECT songID, ip_new_playlistID, track_order FROM makes_up
    WHERE playlistID = ip_playlistID;

end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [3] add_podcast_episode()
-- -----------------------------------------------------------------------------
/* This stored procedure adds a new podcast episode for a creator and associates it with a podcast series.
If the episode is valid, this SP creates the podcast series if it does not already exist, 
inserts the episode as a new content item, links it to the creator, and assigns the next episode number 
in order for that podcast. Ensure that only the non-null input parameters are non-null and 
to enforce domain constraints. Ensure that the creator exists, that the content ID is not already used,
and that if the podcast already has episodes then those episodes belong to the same creator. 
Ensure that the episode length falls within the allowed range. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_podcast_episode;
delimiter //
create procedure add_podcast_episode(
    in ip_creatorID varchar(20),
    in ip_contentID varchar(20),
	in ip_length int,
    in ip_maturity_rating varchar(20),
	in ip_title varchar(100),
    in ip_release_date date,
	in ip_language varchar(50),
    in ip_topic varchar(50),
	in ip_podcastID varchar(20),
    in ip_podcast_title varchar(100),
	in ip_podcast_description varchar(200)
)
sp_main: begin
	 -- Null checks on required fields
      if ip_creatorID is null or ip_contentID is null or ip_length is null 
        or ip_title is null or ip_release_date is null or ip_podcastID is null
        or ip_language is null or ip_topic is null then
        leave sp_main;
    end if;

	-- Creator must exist in creator table
    if not exists (select * from creator where accountID = ip_creatorID) then
        leave sp_main;
    end if;

	-- contentID must not already exist
    if exists (select * from content where contentID = ip_contentID) then
        leave sp_main;
    end if;

	-- content_length must be >= 60
    if ip_length < 60 then
        leave sp_main;
    end if;

	-- maturity_rating must be either explicit or not
    if ip_maturity_rating not in ('Not Explicit', 'Explicit') then
        leave sp_main;
    end if;

	-- Create podcast series if it doesn't exist
    if not exists (select * from podcast_series where podcastID = ip_podcastID) then
		-- podcast_title is required to create a new series 
        if ip_podcast_title is null then
            leave sp_main;
        end if;
        insert into podcast_series (podcastID, title, description)
        values (ip_podcastID, ip_podcast_title, ip_podcast_description);
    else
		-- If series exists, all existing episodes must belong to this creator
        if exists (
            select * from podcast_episode pe
            join creates c on pe.contentID = c.contentID
            where pe.podcastID = ip_podcastID and c.creatorID <> ip_creatorID
        ) then
            leave sp_main;
        end if;
    end if;
	
    -- Insert into content
    insert into content (contentID, title, content_length, maturity, content_language, release_date)
    values (ip_contentID, ip_title, ip_length, ip_maturity_rating, ip_language, ip_release_date);
	
    -- Insert into podcast_episode
    insert into podcast_episode (contentID, podcastID, topic, episode_number)
    select
        ip_contentID,
        ip_podcastID,
        ip_topic,
        coalesce(max(episode_number), 0) + 1
    from podcast_episode
    where podcastID = ip_podcastID;

	-- Link creator to content via creates table
    insert into creates (contentID, creatorID)
    values (ip_contentID, ip_creatorID);
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [4] stream_content()
-- -----------------------------------------------------------------------------
/* This stored procedure starts streaming a specific piece of content for a listener 
by updating what content the listener is currently streaming. It enforces age and maturity 
restrictions so that underage listeners cannot stream explicit content. 
Ensure that the inputs are non-null and that both the listener and content exist. 
Ensure that the listener’s age is computed from their birthdate and that if the content is marked 'Explicit' 
the listener is at least 18 years old before updating their currently streamed content. Timestamp
is set to 0, when content begins streaming. 
HINT: TIMESTAMPDIFF() and CURDATE() can be useful here. */
-- -----------------------------------------------------------------------------
drop procedure if exists stream_content;
delimiter //
create procedure stream_content(
    in ip_listenerID varchar(20),
    in ip_contentID varchar(20)
)
sp_main: begin
	declare v_maturity varchar(20);
    declare v_age int;

    -- Null checks
    if ip_listenerID is null or ip_contentID is null then
        leave sp_main;
    end if;

    -- Listener must exist
    if not exists (select * from listener where accountID = ip_listenerID) then
        leave sp_main;
    end if;

    -- Content must exist
    if not exists (select * from content where contentID = ip_contentID) then
        leave sp_main;
    end if;

    -- Get maturity rating of the content
    select maturity into v_maturity
    from content
    where contentID = ip_contentID;

    -- If explicit, check listener's age from their user birthdate
    if v_maturity = 'Explicit' then
        select timestampdiff(year, u.bdate, curdate()) into v_age
        from user u
        where u.accountID = ip_listenerID;

        if v_age < 18 then
            leave sp_main;
        end if;
    end if;

    -- Update the listener's current stream and reset timestamp to 0
    update listener
    set streams = ip_contentID,		
        timestamp = 0
    where accountID = ip_listenerID;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [5] add_friend_connection()
-- -----------------------------------------------------------------------------
/* This stored procedure records a friendship connection between two listeners. 
Ensure that inputs are non-null, a listener does not friend themself, and 
both listener ids refer to existing listeners and that there is not already a friendship between the 
two accounts before recording the new friendship. Also ensure that ip_listenerID1 is the friender. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_friend_connection; 
delimiter //
create procedure add_friend_connection (
	in ip_listenerID1 varchar(20), 
    in ip_listenerID2 varchar(20)
)
sp_main: begin
	# Ensure that inputs are non-null
    if ip_listenerID1 is null then leave sp_main; end if;
    if ip_listenerID2  is null then leave sp_main; end if;
    # A listener does not friend themself
    if ip_listenerID1 = ip_listenerID2 then leave sp_main; end if;
    # Both listener ids refer to existing listeners
    if not exists (select * from listener where accountID = ip_listenerID1) then leave sp_main; end if;
    if not exists (select * from listener where accountID = ip_listenerID2) then leave sp_main; end if;
    # There is not already a friendship between the two accounts
    # before recording the new friendship
    if exists (select * from friends where friender = ip_listenerID1 and friendee = ip_listenerID2) then leave sp_main; end if;
    # Insert values and ensure that ip_listenerID1 is the friender
    insert into friends (friender, friendee) values (ip_listenerID1, ip_listenerID2);
end //
delimiter ; 

-- -----------------------------------------------------------------------------
-- [6] pin_content()
-- -----------------------------------------------------------------------------
/* This stored procedure pins one of a creator’s content to their profile.
 It updates the creator so that the given content becomes the content shown on their creator page.
 Ensure that the inputs are non-null and that the content and creator exists. 
 Ensure that the song belongs to the given creator. */
-- -----------------------------------------------------------------------------
drop procedure if exists pin_content; 
delimiter //
create procedure pin_content(
	in ip_creatorID varchar(20),
	in ip_contentID varchar(20)
)
sp_main: begin
	# Exit if inputs are null
	if ip_creatorID or ip_contentID is null then leave sp_main;
    end if;
    if not exists (select * from creator where accountID = ip_creatorID) then leave sp_main;
    end if;
    if not exists (select * from content where contentID = ip_contentID) then leave sp_main;
    end if;
    # Ensure the song belongs to the given creator
    if not exists (select * from creates where contentID = ip_contentID and creatorID = ip_creatorID) then leave sp_main;
    end if;
	# Update table
    update creator set pinned = ip_contentID where accountID = ip_creatorID;
end //
delimiter ; 

-- -----------------------------------------------------------------------------
-- [7] cancel_subscription()
-- -----------------------------------------------------------------------------
/* This stored procedure cancels an existing subscription and removes related data for 
listeners on that subscription. It removes friendships where either friend is a listener participating
in this subscription, deletes all playlists owned by listeners participating in this subscription, 
and removes the subscription record itself so that the plan is no longer active.
Ensure that the subscription ID is non-null and that it refers to an existing subscription. */
-- -----------------------------------------------------------------------------
drop procedure if exists cancel_subscription;
delimiter //
create procedure cancel_subscription(in ip_subscription_id varchar(20))
sp_main: begin
    #ensure subscription ID is non null and exists
    IF ip_subscription_id IS NULL OR ip_subscription_id NOT IN (SELECT subscriptionID FROM subscription) THEN
		LEAVE sp_main;
	END IF;
DELETE FROM friends 
WHERE
    friender IN (SELECT 
        accountID
    FROM
        listener
    WHERE
        subscription = ip_subscription_id)
    OR friendee IN (SELECT 
        accountID
    FROM
        listener
    WHERE
        subscription = ip_subscription_id);
DELETE FROM playlist 
WHERE
    listenerID IN (SELECT 
        accountID
    FROM
        listener
    WHERE
        subscription = ip_subscription_id);
DELETE FROM subscription 
WHERE
    subscriptionID = ip_subscription_id;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [8] create_playlist()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new playlist for a listener and adds an initial song to it. 
It looks up the listener by username, creates a new playlist owned by the listener, 
and then adds the requested song to the new playlist. Ensure that the inputs are all non-null. 
Ensure that the username corresponds to an existing listener, that the content ID refers to an existing song, 
and that the playlist ID is not already in use in the playlist table before inserting the new playlist. Also ensure
that listeners without subscriptions will not have more than 5 playlists in total.
HINT: You should complete add_song_to_playlist before this procedure! */
-- -----------------------------------------------------------------------------
drop procedure if exists create_playlist;
delimiter //
create procedure create_playlist(
    in ip_username varchar(100),
    in ip_playlist_name varchar(100),
    in ip_playlistID varchar(20),
    in ip_contentID varchar(20)
)
sp_main: begin
    declare v_listenerID varchar(20);
    declare playlistCount int;
    
    if ip_username is null or ip_playlist_name is null
		or ip_playlistID is null or ip_contentID is null then
		leave sp_main;
	end if;
		
	if not exists (select * from listener where username = ip_username) then
		leave sp_main;
	end if;
    
	select accountID into v_listenerID from listener where username = ip_username;
    select count(*) into playlistCount from playlist where listenerID = v_listenerID;
    
    if playlistCount >= 5 then
		if (select subscription from listener where accountID = v_listenerID) is null then
			leave sp_main;
		end if;
	end if;
    
    if not exists (select * from song where contentID = ip_contentID) then
		leave sp_main;
	end if;
    
    if exists (select * from playlist where playlistID = ip_playlistID) then
		leave sp_main;
	end if;
    
    insert into playlist (playlistID, name, listenerID)
    values (ip_playlistID, ip_playlist_name, v_listenerID);
    
    call add_song_to_playlist(ip_username, ip_playlistID, ip_contentID);

end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [9] add_song_to_playlist()
-- -----------------------------------------------------------------------------
/* This stored procedure adds a song to one of a listener’s playlists. 
It looks up the listener by username and inserts the song into that playlist if it is not already present. 
Ensure that the inputs are all non-null and that the username refers to an existing listener. 
Ensure that the playlist with the given ID exists and is owned by that listener, 
that the content id refers to an existing song, and that the song is not already in the playlist. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_song_to_playlist;
delimiter //
create procedure add_song_to_playlist(
    in ip_username varchar(100),
    in ip_playlistID varchar(20),
    in ip_contentID varchar(20)
)
sp_main: begin
    declare ip_listenerID varchar(20);
	declare ip_track_order int;
    select accountID into ip_listenerID from listener where username = ip_username;
    select (coalesce(max(track_order),0) +1) into ip_track_order from makes_up where playlistID = ip_playlistID;

    if not exists (select * from playlist where playlistID = ip_playlistID and listenerID = ip_listenerID) then leave sp_main; end if;
    # Ensure that the inputs are all non-null
    if ip_username is null then leave sp_main; end if;
    if ip_playlistID is null then leave sp_main; end if;
    if ip_contentID is null then leave sp_main; end if;
    if ip_listenerID is null then leave sp_main; end if;
   
    if not exists (select * from song where contentID = ip_contentID) then leave sp_main; end if;
    # That the song is not already in the playlist (no duplicates)
    if exists (select * from makes_up where songID = ip_contentID and playlistID = ip_playlistID) then leave sp_main; end if;
    insert into makes_up (songID, playlistID, track_order) values (ip_contentID, ip_playlistID, ip_track_order);
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [10] start_playlist()
-- -----------------------------------------------------------------------------
/* This stored procedure starts streaming the first song (in alphabetical order by title)
from a given playlist for a given listener. Ensure non-null input, that the listener
exists, that the playlist exists, and that the playlist belongs to the listener. 
If a playlist does not have any songs, then nothing should occur. Calling another 
previously implemented stored procedure to start streaming would be useful here! */
-- -----------------------------------------------------------------------------
drop procedure if exists start_playlist;
delimiter //
create procedure start_playlist(
    in ip_username varchar(100),
    in ip_playlistID varchar(20)
)
sp_main: begin
        declare v_listenerID varchar(20);
    declare v_contentID varchar(20);

    -- Null checks
    if ip_username is null or ip_playlistID is null then
        leave sp_main;
    end if;

    -- Listener must exist, resolve username to accountID
    if not exists (select * from listener where username = ip_username) then
        leave sp_main;
    end if;

    select accountID into v_listenerID
    from listener
    where username = ip_username;

    -- Playlist must exist
    if not exists (select * from playlist where playlistID = ip_playlistID) then
        leave sp_main;
    end if;

    -- Playlist must belong to this listener
    if not exists (select * from playlist 
			where playlistID = ip_playlistID 
			and listenerID = v_listenerID) then
        leave sp_main;
    end if;

    -- Get the first song alphabetically by title from the playlist
    -- If no songs exist, nothing occurs (select returns null, call is skipped)
    select c.contentID into v_contentID
    from makes_up mu
    join content c on mu.songID = c.contentID
    where mu.playlistID = ip_playlistID
    order by c.title asc
    limit 1;

    -- If playlist has no songs, v_contentID will be null so we exit
    if v_contentID is null then
        leave sp_main;
    end if;

    -- Reuse stream_content to handle age/maturity checks and update listener
    call stream_content(v_listenerID, v_contentID);

end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [11] create_user()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new user account, which can be a creator, listener, or both.
Ensure non-null input for account ID, full name, birthdate, and email. Ensure that the
account ID is unique in the user table. Ensure that the user
is at least 13 years old based on the birthdate provided. If the user is a listener, ensure that
the username is non-null, and if streams is non-null, it references an
existing content and that time stamp is set to 0. Use the passed in enum ip_user_type to determine if the user is a creator,
listener, or both. If the user is both, but the listener-related validations fail (e.g., username
and/or streams is invalid), then no data should be inserted into either
listener or creator.
HINT: TIMESTAMPDIFF() can be helpful here. */
-- -----------------------------------------------------------------------------
drop procedure if exists create_user; 
delimiter //
create procedure create_user (
	in ip_accountID varchar(20), 
    in ip_fullname varchar(100), 
    in ip_birthdate date, 
    in ip_email varchar(200),
    in ip_username varchar(100), 
    in ip_stagename varchar(100), 
    in ip_bio varchar(200), 
    in ip_currentlyStreaming varchar(20),
    in ip_user_type enum('creator', 'listener', 'both')
)
sp_main: begin
	declare age int;
    
    if ip_accountID is null or ip_fullname is null
		or ip_birthdate is null or ip_email is null or ip_user_type is null
		then leave sp_main;
	end if;
    
    if exists (select * from user where accountID = ip_accountID) then 
		leave sp_main;
	end if;
    
    set age = timestampdiff(year, ip_birthdate, curdate());
    if age < 13 then
		leave sp_main;
	end if;
    
    
    if ip_user_type in ('listener', 'both') then
    
		if ip_username is Null then
			leave sp_main;
		end if;
        
        if ip_currentlyStreaming is not Null then
			if not exists (select * from content where contentID = ip_currentlyStreaming) then
				leave sp_main;
			end if; 
		end if;
	end if;
        
        
    insert into user(AccountID, name, bdate, email)
    values(ip_accountID, ip_fullname, ip_birthdate, ip_email);
    
    if ip_user_type in ('creator', 'both') then
        insert into creator (accountID, stage_name, biography, pinned)
        values (ip_accountID, ip_stagename, ip_bio, null);
    end if;
    
	if ip_user_type in ('listener', 'both') then
        insert into listener (accountID, username, streams, timestamp, subscription)
        values (ip_accountID, ip_username, ip_currentlyStreaming,
                case when ip_currentlyStreaming is not null then 0 else null end,
                null);
    end if;

end //
delimiter ; 

-- -----------------------------------------------------------------------------
-- [12] upload_song()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a creator to upload a new song to the platform.
Ensure non-null inputs for all fields except album name (which is optional).
Ensure that the content ID is unique, that the creator ID exists in the creator table,
that the album (if provided) exists and is owned by the creator, and that the
album has fewer than 16 songs. Also, ensure that the content length is between
60 and 600 seconds. All creators with songs on the platform need a stage name.
If this artist does not already have a stage name, set it to their full name
(from the user table). Otherwise, leave it as it currently is.

HINT: Make sure to add data to all relevant tables within the database. */
-- -----------------------------------------------------------------------------
drop procedure if exists upload_song; 
delimiter //
create procedure upload_song (
	in ip_contentID varchar(20), 
    in ip_contentLength int, 
    in ip_title varchar(100), 
    in ip_maturity enum('Not Explicit', 'Explicit'), 
    in ip_contentLanguage varchar(50), 
    in ip_releaseDate date, 
    in ip_creatorID varchar(20), 
    in ip_albumName varchar(100)
)
sp_main: begin
	declare ip_stage_name varchar(100);
    declare ip_fullname varchar(100);
    select stage_name into ip_stage_name from creator where accountID = ip_creatorID;
    select name into ip_fullname from user where accountID = ip_creatorID;
	# Ensure non-null inputs for all fields except album name (which is optional).
    if ip_contentID is null then leave sp_main; end if;
    if ip_contentLength is null then leave sp_main; end if;
    if ip_title is null then leave sp_main; end if;
    if ip_maturity is null then leave sp_main; end if;
    if ip_contentLanguage is null then leave sp_main; end if;
    if ip_releaseDate is null then leave sp_main; end if;
    if ip_creatorID is null then leave sp_main; end if;
    # Ensure that the content ID is unique
    if exists (select * from content where contentID = ip_contentID) then leave sp_main; end if; -- content is unique
    # the creator ID exists in the creator table
    if not exists (select * from creator where accountID = ip_creatorID) then leave sp_main; end if;
    # the album (if provided) exists and is owned by the creator
    if ip_albumName is not null then
		if not exists (select * from album where album_name = ip_albumName) then leave sp_main; end if;
		# the album has fewer than 16 songs
		if (select count(*) from song where album_name = ip_albumName) >= 16 then leave sp_main; end if; 
    end if;
    # ensure that the content length is between 60 and 600 seconds
    if ip_contentLength < 60 then leave sp_main; end if;
    if ip_contentLength > 600 then leave sp_main; end if;
    # All creators with songs on the platform need a stage name
    # If this artist does not already have a stage name, set it to their full name
	# (from the user table). Otherwise, leave it as it currently is.
    if ip_stage_name is null then set ip_stage_name = ip_fullname; end if;
    
    insert into content (contentID, title, content_length, maturity, content_language, release_date) 
    values (ip_contentID, ip_title, ip_contentLength, ip_maturity, ip_contentLanguage, ip_releaseDate);
    insert into creates (contentID, creatorID) values (ip_contentID, ip_creatorID);
    insert into song (contentID, creatorID, album_name) values (ip_contentID, ip_creatorID, ip_albumName);
end //
delimiter ; 

-- -----------------------------------------------------------------------------
-- [HELPER PROCEDURE] resequence_track_order()
-- -----------------------------------------------------------------------------
/* This helper procedure resequences the track order of all songs in a given
playlist so that they are numbered consecutively starting from 1, preserving
their original relative order. */
-- -----------------------------------------------------------------------------
drop procedure if exists resequence_track_order;
delimiter //
create procedure resequence_track_order (
    in ip_playlistID varchar(20)
)
sp_main: begin
    declare curr_songID varchar(20);
    declare counter int default 1;
	declare total int;

    select count(*) into total from makes_up where playlistID = ip_playlistID;

    while counter <= total do
        select songID into curr_songID from makes_up
        where playlistID = ip_playlistID and track_order >= counter
        order by track_order asc
        limit 1;

        update makes_up
        set track_order = counter
        where songID = curr_songID and playlistID = ip_playlistID;

        set counter = counter + 1;
    end while;
end //
delimiter ;

-- -----------------------------------------------------------------------------
-- [13] delete_playlist_songs()
-- -----------------------------------------------------------------------------
/* This stored procedure deletes song IDs containing the input character/phrase
from the input playlist. Ensure non-null inputs and that the playlist exists. If 
no songs in the playlist contain the input character/phrase, then nothing is deleted.
After deleting songs, you will have to rearrange the track orders. We have provided you
a helper function, resequence_track_order(), that you might find especially useful. 
If a playlist has no songs left, then also delete the entire playlist. */
-- -----------------------------------------------------------------------------
drop procedure if exists delete_playlist_songs;
delimiter //
create procedure delete_playlist_songs (
    in ip_playlistID varchar(20),
    in ip_char_phrase varchar(20)
)
sp_main: begin
	#Ensure non-null
    IF ip_playlistID IS NULL OR ip_char_phrase IS NULL THEN
		LEAVE sp_main;
	END IF;
    
    #ensure playlist exists
    IF ip_playlistID NOT IN (SELECT playlistID FROM playlist) THEN
		LEAVE sp_main;
	END IF;
    
    #if phrase not in song in playlist then nothing is deleted
	IF ip_playlistID NOT IN (SELECT playlistID FROM makes_up WHERE
    playlistID = ip_playlistID AND
    songID LIKE CONCAT('%', ip_char_phrase, '%')) THEN
		LEAVE sp_main;
	END IF;
    
    #Delete songs with that phrase
    DELETE FROM makes_up WHERE playlistID = ip_playlistID
    AND songID LIKE CONCAT('%', ip_char_phrase, '%');
    
    #Rearrange
    CALL resequence_track_order(ip_playlistID);
    
    #If no songs left then delete
    IF ip_playlistID NOT IN (SELECT playlistID FROM makes_up) THEN
		DELETE FROM playlist WHERE ip_playlistID = playlistID;
	END IF;
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [14] merge_playlists()
-- -----------------------------------------------------------------------------
/* This stored procedure merges two playlists into one. The songs from the second
playlist are added to the first playlist with track orders continuing from the
first playlist's current maximum, and then the second playlist is deleted. Duplicate 
songs (already in the first playlist) are removed from the second playlist before 
merging. Due to duplicate songs, the track_order might lose sequential order. We have
provided you a helper function, resequence_track_order(), that you might find especially 
useful to handle this issue.  Ensure non-null inputs, that both playlists exist, that 
both playlists are not the same, and that both playlists belong to the same listener. 

HINT: When you delete songs from playlist 2 that are already in playlist 1, you might need 
to use a nested query with aliasing. 
*/
-- -----------------------------------------------------------------------------
drop procedure if exists merge_playlists;
delimiter //
create procedure merge_playlists (
    in ip_playlistID1 varchar(20), -- first playlist
    in ip_playlistID2 varchar(20) -- second playlist
)
sp_main: begin
	#Declare 
    DECLARE listener_ID1 varchar(20);
    DECLARE listener_ID2 varchar(20);
    DECLARE m_track_order INT;
    
	#Ensure non-null
    IF ip_playlistID1 IS NULL OR ip_playlistID2 IS NULL THEN
		LEAVE sp_main;
	END IF;
    
    #ensure both playlists exist
    IF ip_playlistID1 NOT IN (SELECT playlistID FROM playlist)
    OR ip_playlistID2 NOT IN (SELECT playlistID FROM playlist) THEN
		LEAVE sp_main;
	END IF;
    
	#Ensure both playlists are not the same
    IF ip_playlistID1 = ip_playlistID2 THEN
		LEAVE sp_main;
	END IF;
    
    #Get variable info
    SELECT listenerID INTO listener_ID1 FROM playlist WHERE playlistID = ip_playlistID1;
    SELECT listenerID INTO listener_ID2 FROM playlist WHERE playlistID = ip_playlistID2;

    #Ensure both playlists belong to the same listener
    IF listener_ID1 != listener_ID2 THEN
		LEAVE sp_main;
	END IF;
    
    #Remove duplicate songs
    DELETE FROM makes_up WHERE playlistID = ip_playlistID2
    AND songID IN (SELECT songID FROM 
    (SELECT songID FROM makes_up WHERE playlistID = ip_playlistID1)
    AS play);
    
    #Find current track order
    SELECT IFNULL(MAX(track_order), 0) INTO m_track_order
    FROM makes_up WHERE playlistID = ip_playlistID1;
    
    #change playlist trackorders to fit playlist 1
    UPDATE makes_up SET track_order = track_order + m_track_order
    WHERE playlistID = ip_playlistID2;
    
    #change songs from playlist 2 to playlist 1
    UPDATE makes_up SET playlistID = ip_playlistID1
    WHERE playlistID = ip_playlistID2;
    
    #Delete emptied playlist 2
    DELETE FROM playlist WHERE playlistID = ip_playlistID2;
    
    #Fix order
    CALL resequence_track_order(ip_playlistID1);
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [15] stop_stream()
-- -----------------------------------------------------------------------------
/* This stored procedure stops a listener from streaming any content by setting
their currently streaming content to null. Ensure non-null input, that the
account is a listener, and that the listener is currently streaming content. */
-- -----------------------------------------------------------------------------
drop procedure if exists stop_stream;
delimiter //
create procedure stop_stream (
	in ip_accountID varchar(20) -- listener
)
sp_main: begin
    declare ip_streams varchar(20);
    select streams into ip_streams from listener where accountID = ip_accountID;
     # Ensure non-null input
     if ip_accountID is null then leave sp_main; end if;
     # Ensure the account is a listener
     if not exists (select * from listener where accountID = ip_accountID) then leave sp_main; end if;
     # Ensure that the listener is currently streaming content
     if ip_streams is null then leave sp_main; end if;
     # Set to null
     update listener set streams = null where accountID = ip_accountID;
     update listener set timestamp = null where accountID = ip_accountID;
     
end //
delimiter ;
-- -----------------------------------------------------------------------------
-- [16] add_feature
-- -----------------------------------------------------------------------------
/* This stored procedure associates a creator to an existing piece of content. 
Ensure non-null parameters and that the creator ID is valid. Because the creator
is being featured rather than creating the content, the referenced content must
already exist. Also, ensure that this feature is not already recorded. Ensure that
the content has no more than 5 creators associated with it. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_feature;
delimiter //
create procedure add_feature (
	in ip_contentID varchar(20), 
    in ip_creatorID varchar(20)
)
sp_main: begin
    # Ensure non-null parameters
    if ip_contentID is null then leave sp_main; end if;
    if ip_creatorID is null then leave sp_main; end if;
    # Ensure that the creatorID is valid
    if not exists (select * from creates where creatorID = ip_creatorID) then leave sp_main; end if;
    # The referenced content must already exist
    if not exists (select * from creates where contentID = ip_contentID) then leave sp_main; end if;
    # Ensure that this feature is not already recorded
    
    # Ensure that the content has no more than 5 creators associated with it
    if (select count(*) from creates where creatorID = ip_creatorID) > 5 then leave sp_main; end if;
    insert into creates (contentID, creatorID) values (ip_contentID, ip_creatorID);
end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [17] delete_episodes()
-- -----------------------------------------------------------------------------
/* This stored procedure deletes the given number of podcast episodes from a podcast 
series as well as from the database. Ensure non-null parameters and that the podcast series
exists. Also ensure that the given number is non-negative. If the number is 
greater than the number of episodes in the series, do not delete any episodes. 
Delete episodes in descending order, starting from the highest episode number. */
-- -----------------------------------------------------------------------------
drop procedure if exists delete_episodes;
delimiter //
create procedure delete_episodes (
	in ip_podcastID varchar(20),
    in ip_num_episodes int
)
sp_main: begin
    declare current_num int;
    
    if not exists (select * from podcast_series where podcastID = ip_podcastID) then
		leave sp_main;
	end if;
    
    if ip_podcastID is null or ip_num_episodes is null then
		leave sp_main;
	end if;
    
    if ip_num_episodes < 0 then
		leave sp_main;
	end if;
    
    select count(*) into current_num from podcast_episode where podcastID = ip_podcastID;
    
    if ip_num_episodes > current_num then
		leave sp_main;
	end if;
    
    delete from content where contentID in (
		select contentID from (
			select contentID from podcast_episode where podcastID = ip_podcastID
            order by episode_number desc limit ip_num_episodes) as del);

end //
delimiter ;


-- -----------------------------------------------------------------------------
-- [18] remove_socials
-- -----------------------------------------------------------------------------
/* This stored procedure deletes all except for one social media handle for a
creator. Ensure that the input creator ID is a valid creator ID. The handle to 
keep is determined by the following priority rules (from highest to lowest): 
1) If the creator participates in any podcast series, keep the TikTok handle 
if the creator has one. 2) If the creator has created at least 2 albums, keep 
the creator's SoundCloud handle. 3) If the creator was born on or after January 1, 2000, 
keep the creator's Snapchat. 4) Otherwise, delete all handles except
for the alphabetically first social media handle under that creator.

After these deletions, if the creator doesn't have any social media information listed,
add back the creator's originally alphabetically first social media handle. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_socials;
delimiter //
create procedure remove_socials (
	in ip_creatorID varchar(20)
)
sp_main: begin
    DECLARE kept_handle VARCHAR(50) DEFAULT NULL;
    DECLARE first_handle VARCHAR(50) DEFAULT NULL;
    
    #Ensure input creator is valid
    IF ip_creatorID IS NULL OR ip_creatorID NOT IN (SELECT accountID FROM creator) THEN
		LEAVE sp_main;
	END IF;
    
    #get the first_handle
    SELECT handle INTO first_handle FROM socials
    WHERE creatorID = ip_creatorID ORDER BY handle ASC LIMIT 1;
    
    #if no handles then leave
    IF first_handle IS NULL THEN
		LEAVE sp_main;
	END IF;
    
    #determine which handle to keep
    
    #1: podcast series
    IF ip_creatorID IN (SELECT creatorID FROM creates WHERE contentID IN (SELECT podcastID FROM podcast_series)) THEN
		SELECT handle INTO kept_handle FROM socials WHERE ip_creatorID = creatorID AND platform = 'Tiktok' LIMIT 1;
	END IF;
    
    #2: >= 2 albums
    IF kept_handle IS NULL AND (SELECT COUNT(*) FROM album WHERE creatorID = ip_creatorID) >=2 THEN
		SELECT handle INTO kept_handle FROM socials WHERE ip_creatorID = creatorID AND platform = 'SoundCloud' LIMIT 1;
	END IF;
    
    #3: bdate
    IF kept_handle IS NULL AND (SELECT bdate FROM user WHERE accountID = ip_creatorID) >= '2000-01-01' THEN
		SELECT handle INTO kept_handle FROM socials WHERE ip_creatorID = creatorID AND platform = 'Snapchat' LIMIT 1;
	END IF;
    
    #4: first handle
	IF kept_handle IS NULL THEN
		SET kept_handle = first_handle;
	END IF;
    
    #Delete
    DELETE FROM socials WHERE creatorID = ip_creatorID AND handle != kept_handle;

end //
delimiter ;
