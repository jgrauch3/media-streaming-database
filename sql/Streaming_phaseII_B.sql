-- Phase II B: Insert Statements + Views [v1] [February 23rd, 2026]

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'media_streaming_service';
use media_streaming_service;

drop procedure if exists magic44_reset_database_state;
delimiter //
create procedure magic44_reset_database_state ()
begin
	DELETE FROM album;
	DELETE FROM content;
	DELETE FROM creates;
    DELETE FROM creator;
	DELETE FROM friends;
	DELETE FROM genres;
    DELETE FROM listener;
	DELETE FROM makes_up;
    DELETE FROM playlist;
    DELETE FROM podcast_episode;
	DELETE FROM podcast_series;
	DELETE FROM socials;
	DELETE FROM song;
	DELETE FROM subscription;
	DELETE FROM user;

    /* You must enter your data insertion statements below here.  You may sequence them in
    any order that works for you (and runs successfully).  When executed, your statements must create 
    a functional database that contains all of the data and supports as many of the constraints as possible. */
INSERT INTO user VALUES('JS9083', 'Joe Smith', '1990-12-01', 'joesmith90@mail.com');
INSERT INTO user VALUES('SM6701', 'Sarah Moore', '1992-06-22', 'sarahmoore@mail.com');
INSERT INTO user VALUES('MD5481', 'Maya Delgado', '1995-03-22', 'maya.delgado@mail.com');
INSERT INTO user VALUES('AB8247', 'Andre Bennett', '1992-07-11', 'andrebennett@music.io');
INSERT INTO user VALUES('LK7653', 'Lisa Keller', '1998-01-30', 'lenakhan@mail.com');
INSERT INTO user VALUES('KI4328', 'Kevin Ingram', '1989-03-14', 'kevin.ingram@mail.com');
INSERT INTO user VALUES('PN7413', 'Priya Nair', '1996-12-17', 'priya.nair@mail.com');
INSERT INTO user VALUES('DM1120', 'Daniel Moore', '2000-05-09', 'dan.moore@mail.com');
INSERT INTO user VALUES('CM7782', 'Chloe Moore', '2009-09-21', 'chloe.moore@mail.com');
INSERT INTO user VALUES('MC9055', 'Malik Carter', '1991-10-19', 'malik.carter@studio.fm');
INSERT INTO user VALUES('TS4389', 'Theo Schmidt', '1993-02-14', 'tchmidt@mindcast.app');
INSERT INTO user VALUES('JM5520', 'Jonah Marks', '1994-11-02', 'jonah.marks@mail.com');
INSERT INTO user VALUES('AH1050', 'Adam Hart', '1990-07-29', 'ahart@mail.com');

INSERT INTO content VALUES ('SKYBLUE', 'Sky So Blue', 95, 'Not Explicit', 'English', '2023-09-12');
INSERT INTO content VALUES ('SHIPPING', 'Shipping Without Maps', 3551, 'Not Explicit', 'English', '2023-04-22');
INSERT INTO content VALUES ('ECHOES', 'City of Echoes', 131, 'Not Explicit', 'English', '2024-05-04');
INSERT INTO content VALUES ('ORBIT', 'Midnight Orbit', 688, 'Explicit', 'German', '2024-01-15');
INSERT INTO content VALUES ('BURNOUT', 'Burnout Reset', 1914, 'Not Explicit', 'English', '2024-02-11');
INSERT INTO content VALUES ('SUNSET', 'Sunset Grove', 782, 'Not Explicit', 'English', '2023-11-03');
INSERT INTO content VALUES ('PAPER', 'Paper Skies', 178, 'Not Explicit', 'English', '2022-07-18');
INSERT INTO content VALUES ('POLAROID', 'Polaroid Walls', 185, 'Not Explicit', 'English', '2024-03-22');
INSERT INTO content VALUES ('METRICS', 'Metrics That Matter', 3262, 'Not Explicit', 'French', '2023-05-20');
INSERT INTO content VALUES ('MEADOW', 'Meadow Night', 144, 'Explicit', 'English', '2023-09-12');
INSERT INTO content VALUES ('BOUNDARY', 'Boundaries 101', 2741, 'Not Explicit', 'English', '2024-01-14');
INSERT INTO content VALUES ('VELVET', 'Velvet Raag', 201, 'Not Explicit', 'English', '2024-05-04');
INSERT INTO content VALUES ('CHECKOUT', 'Late Checkout', 182, 'Explicit', 'English', '2022-07-18');
INSERT INTO content VALUES ('SCALE', 'Scaling Chaos', 2212, 'Not Explicit', 'English', '2024-09-15');
INSERT INTO content VALUES ('MIDNIGHT', 'Midnight Pool', 156, 'Not Explicit', 'English', '2023-03-10');
INSERT INTO content VALUES ('TIDES', 'Neon Tides', 168, 'Explicit', 'Spanish', '2023-03-10');
INSERT INTO content VALUES ('RESILIENCE', 'Everyday Resilience', 2535, 'Not Explicit', 'English', '2024-06-02');
INSERT INTO content VALUES ('BRASS', 'Brass Wires', 179, 'Not Explicit', 'English', '2024-03-22');
INSERT INTO content VALUES ('LOVE', 'Friendly Talks Ep 1: Love', 1800, 'Not Explicit', 'English', '2025-02-15');

INSERT INTO subscription VALUES('S4738', 360.00, '2025-02-01', '2025-12-31', NULL, 5, 'Family');
INSERT INTO subscription VALUES('S1234', 119.99, '2025-02-01', '2025-12-31', NULL, 3, 'Family');
INSERT INTO subscription VALUES('S2345', 205.55, '2024-05-13', '2025-04-30', 'Premium', NULL, 'Individual');
INSERT INTO subscription VALUES('S9876', 299.99, '2024-08-20', '2025-08-19', 'Deluxe', NULL, 'Individual');
INSERT INTO subscription VALUES('S5566', 111.45, '2025-03-10', '2026-05-01', 'Premium', NULL, 'Individual');

INSERT INTO listener VALUES('JS9083', 'superFanJS20', 'SKYBLUE', 64, 'S4738');
INSERT INTO listener VALUES('SM6701', 'ssarah', 'ECHOES', 19, 'S1234');
INSERT INTO listener VALUES('LK7653', 'lklikessongs', 'POLAROID', 142, 'S2345');
INSERT INTO listener VALUES('KI4328', 'kevbeats', 'SHIPPING', 231, 'S9876');
INSERT INTO listener VALUES('DM1120', 'dmoore2000', 'SKYBLUE', 33, 'S1234');
INSERT INTO listener VALUES('CM7782', 'chloemoore', 'POLAROID', 41, 'S1234');
INSERT INTO listener VALUES('JM5520', 'markstunes', NULL, NULL, 'S5566');
INSERT INTO listener VALUES('TS4389', 'theos23', 'POLAROID', 178, NULL);
INSERT INTO listener VALUES('AH1050', 'awesomeadam', 'TIDES', 89, NULL);

INSERT INTO creator VALUES('JS9083', 'Young Sean', 'I write songs for the greatest moments in life.', 'SKYBLUE');
INSERT INTO creator VALUES('MD5481', 'Delga', 'LA-based indie-pop singer blending bilingual hooks with lo-fi beats', 'PAPER');
INSERT INTO creator VALUES('AB8247', 'Dre Ben', 'Toronto producer-rapper crafting jazzy boom-bap with modern soul', 'POLAROID');
INSERT INTO creator VALUES('PN7413', 'Priyaaa', NULL, NULL);
INSERT INTO creator VALUES('MC9055', NULL, 'Former startup PM interviewing operators about the messy middle of building products', NULL);
INSERT INTO creator VALUES('TS4389', NULL, 'Therapist hosting conversations on mental health, community, and science-backed practices', NULL);
INSERT INTO creator VALUES('AH1050', NULL, 'Trying to get into the music scene!', NULL);

INSERT into socials values ('JS9083', 'Instagram', 'ysean');
INSERT into socials values ('JS9083', 'Snapchat', 'youngsean');
INSERT into socials values ('JS9083', 'TikTok', 'iamsean');
INSERT INTO socials VALUES('MD5481', 'Instagram', 'delga');
INSERT INTO socials VALUES('MD5481', 'TikTok', 'delgatofficial');
INSERT INTO socials VALUES('MD5481', 'YouTube', 'delgaTV');
INSERT INTO socials VALUES('AB8247', 'Instagram', 'dreben');
INSERT INTO socials VALUES('AB8247', 'Twitter', 'dreben_x');
INSERT INTO socials VALUES('AB8247', 'SoundCloud', 'drebenbeats');
INSERT INTO socials VALUES('PN7413', 'Instagram', 'priyan');
INSERT INTO socials VALUES('PN7413', 'Twitter', 'priyan_x');
INSERT INTO socials VALUES('PN7413', 'Twitch', 'priyanstudio');
INSERT INTO socials VALUES('MC9055', 'Twitter', 'buildmodepod');
INSERT INTO socials VALUES('MC9055', 'LinkedIn', 'malikcarter');
INSERT INTO socials VALUES('MC9055', 'TikTok', 'buildmode_tok');
INSERT INTO socials VALUES('TS4389', 'Instagram', 'mindcast');
INSERT INTO socials VALUES('TS4389', 'TikTok', 'mindcastpod');
INSERT INTO socials VALUES('TS4389', 'Twitch', 'theolive');
INSERT INTO socials VALUES('AH1050', 'Instagram', 'ahartofgold');

INSERT INTO album VALUES('JS9083', 'Starlight Meadows');
INSERT INTO album VALUES('MD5481', 'Sunflower Motel');
INSERT INTO album VALUES('MD5481', 'Night Swim');
INSERT INTO album VALUES('AB8247', 'Copper Lines');
INSERT INTO album VALUES('PN7413', 'Velvet Hour');

INSERT INTO song VALUES ('SKYBLUE', 'JS9083', 'Starlight Meadows');
INSERT INTO song VALUES ('ECHOES', NULL, NULL);
INSERT INTO song VALUES ('PAPER', 'MD5481', 'Sunflower Motel');
INSERT INTO song VALUES ('POLAROID', 'AB8247', 'Copper Lines');
INSERT INTO song VALUES ('MEADOW', 'JS9083', 'Starlight Meadows');
INSERT INTO song VALUES ('VELVET', 'PN7413', 'Velvet Hour');
INSERT INTO song VALUES ('CHECKOUT', 'MD5481', 'Sunflower Motel');
INSERT INTO song VALUES ('MIDNIGHT', 'MD5481', 'Night Swim');
INSERT INTO song VALUES ('TIDES', 'MD5481', 'Night Swim');
INSERT INTO song VALUES ('BRASS', 'AB8247', 'Copper Lines');
 
INSERT INTO genres VALUES ('SKYBLUE', 'Pop');
INSERT INTO genres VALUES ('SKYBLUE', 'Rock');
INSERT INTO genres VALUES ('ECHOES', 'Alternative R&B');
INSERT INTO genres VALUES ('ECHOES', 'Ambient');
INSERT INTO genres VALUES ('ECHOES', 'Chillout');
INSERT INTO genres VALUES ('PAPER', 'Indie Pop');
INSERT INTO genres VALUES ('POLAROID', 'Alternative');
INSERT INTO genres VALUES ('POLAROID', 'Dream Pop');
INSERT INTO genres VALUES ('MEADOW', 'Hip-Hop');
INSERT INTO genres VALUES ('MEADOW', 'Alternative Rap');
INSERT INTO genres VALUES ('VELVET', 'Alternative R&B');
INSERT INTO genres VALUES ('CHECKOUT', 'Indie Pop');
INSERT INTO genres VALUES ('MIDNIGHT', 'Indie Pop');
INSERT INTO genres VALUES ('TIDES', 'Indie Pop');
INSERT INTO genres VALUES ('BRASS', 'Hip-Hop');  

INSERT INTO podcast_series VALUES ('POD1111', 'Build Mode S1', 'Build Mode is an operator-driven conversation about building products—tactics, experiments, metrics, and shipping at speed.');
INSERT INTO podcast_series VALUES ('POD2222', 'Mindcast S1', 'Mindcast is a therapy-informed podcast on mental health, blending evidence-based tools with community care and real stories.');
INSERT INTO podcast_series VALUES ('POD1112', 'Build Mode S2', 'Build Mode is an operator-driven conversation about building products—tactics, experiments, metrics, and shipping at speed.');
INSERT INTO podcast_series VALUES ('POD2323', 'Mindcast S2', 'Mindcast is a therapy-informed podcast on mental health, blending evidence-based tools with community care and real stories.');
INSERT INTO podcast_series VALUES ('POD4895', 'Friendly Talks', 'Friendly Talks is a cozy, curiosity-driven show where thoughtful people unpack everyday topics.');
    
INSERT INTO podcast_episode VALUES ('SHIPPING', 'POD1111', 'Efficiency', '1');
INSERT INTO podcast_episode VALUES ('BURNOUT', 'POD2222', 'Burnout', '2');
INSERT INTO podcast_episode VALUES ('METRICS', 'POD1111', 'Metrics', '2');
INSERT INTO podcast_episode VALUES ('BOUNDARY', 'POD2222', 'Boundaries', '1');
INSERT INTO podcast_episode VALUES ('SCALE', 'POD1112', 'Scaling', '1');
INSERT INTO podcast_episode VALUES ('RESILIENCE', 'POD2323', 'Resilience', '1');
INSERT INTO podcast_episode VALUES ('LOVE', 'POD4895', 'Love', '1');

INSERT INTO playlist VALUES('P2310', 'Car Songs', 'JS9083');
INSERT INTO playlist VALUES('P1111', 'Car Songs', 'SM6701');
INSERT INTO playlist VALUES('P2222', 'Workout Songs', 'SM6701');
INSERT INTO playlist VALUES('P3333', 'Inspiration', 'LK7653');
INSERT INTO playlist VALUES('P2345', 'Favorites', 'KI4328');
INSERT INTO playlist VALUES('P7890', 'Road Trip', 'DM1120');
INSERT INTO playlist VALUES('P2323', 'Weekend Mix', 'JM5520');

INSERT INTO creates VALUES ('SKYBLUE', 'JS9083');
INSERT INTO creates VALUES ('SHIPPING', 'MC9055');
INSERT INTO creates VALUES ('ECHOES', 'PN7413');
INSERT INTO creates VALUES ('ORBIT', 'JS9083');
INSERT INTO creates VALUES ('ORBIT', 'MD5481');
INSERT INTO creates VALUES ('BURNOUT', 'TS4389');
INSERT INTO creates VALUES ('SUNSET', 'MD5481');
INSERT INTO creates VALUES ('SUNSET', 'AB8247');
INSERT INTO creates VALUES ('PAPER', 'MD5481');
INSERT INTO creates VALUES ('POLAROID', 'AB8247');
INSERT INTO creates VALUES ('METRICS', 'MC9055');
INSERT INTO creates VALUES ('MEADOW', 'JS9083');
INSERT INTO creates VALUES ('BOUNDARY', 'TS4389');
INSERT INTO creates VALUES ('VELVET', 'PN7413');
INSERT INTO creates VALUES ('CHECKOUT', 'MD5481');
INSERT INTO creates VALUES ('SCALE', 'MC9055');
INSERT INTO creates VALUES ('MIDNIGHT', 'MD5481');
INSERT INTO creates VALUES ('TIDES', 'MD5481');
INSERT INTO creates VALUES ('RESILIENCE', 'TS4389');
INSERT INTO creates VALUES ('BRASS', 'AB8247');
INSERT INTO creates VALUES ('LOVE', 'JS9083');

INSERT INTO makes_up VALUES ('SKYBLUE', 'P1111', '2');
INSERT INTO makes_up VALUES ('SKYBLUE', 'P2310', '2');
INSERT INTO makes_up VALUES ('ECHOES', 'P1111', '4');
INSERT INTO makes_up VALUES ('ECHOES', 'P2222', '2');
INSERT INTO makes_up VALUES ('ECHOES', 'P3333', '1');
INSERT INTO makes_up VALUES ('ECHOES', 'P7890', '1');
INSERT INTO makes_up VALUES ('POLAROID', 'P3333', '3');
INSERT INTO makes_up VALUES ('POLAROID', 'P2345', '3');
INSERT INTO makes_up VALUES ('POLAROID', 'P1111', '5');
INSERT INTO makes_up VALUES ('MEADOW', 'P1111', '3');
INSERT INTO makes_up VALUES ('MEADOW', 'P2222', '1');
INSERT INTO makes_up VALUES ('MEADOW', 'P7890', '2');
INSERT INTO makes_up VALUES ('VELVET', 'P2345', '1');
INSERT INTO makes_up VALUES ('VELVET', 'P1111', '1');
INSERT INTO makes_up VALUES ('VELVET', 'P2323', '1');
INSERT INTO makes_up VALUES ('MIDNIGHT', 'P2345', '2');
INSERT INTO makes_up VALUES ('MIDNIGHT', 'P1111', '6');
INSERT INTO makes_up VALUES ('TIDES', 'P2310', '1');
INSERT INTO makes_up VALUES ('TIDES', 'P2345', '5');
INSERT INTO makes_up VALUES ('BRASS', 'P3333', '2');
INSERT INTO makes_up VALUES ('BRASS', 'P2345', '4');


	
	/* Do not modify the friender column! Only fill in the friendee column. */
	insert into friends (friender, friendee) values
	('SM6701', 'LK7653' ), 
	('SM6701', 'KI4328'),
	('KI4328', 'LK7653' ),
	('DM1120',  'SM6701' ), 
	('DM1120', 'CM7782'),
	('CM7782',  'SM6701' ),
	('JM5520', 'KI4328'),
	('JS9083', 'LK7653' );
end //
delimiter ;

call magic44_reset_database_state();

-- ---------------------------------------------------------------------------------------------------------
-- Insert statements begin on line 49, implement views below.
-- !!! Do not forget to start your queries with "create or replace view ... as" !!!
-- ---------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- [1] creator_songs_view()
-- -----------------------------------------------------------------------------
/* This view displays information about the total streams and songs for each creator.
For every creator with a non-null stage name, it displays their stage name,
the total number of listeners currently streaming any of that creator’s songs,
and a list of the creator's song titles in descending order of current streams
(in the case of ties, order by ascending song title), separated by a comma and a space.
HINT: the GROUP_CONCAT function can be useful here. */
-- -----------------------------------------------------------------------------
create or replace view creator_songs_view as
SELECT cr.stage_name as creator_stage_name, SUM(songs.stream) AS total_streams, 
GROUP_CONCAT(songs.title ORDER BY songs.stream DESC, songs.title ASC
SEPARATOR ', ') AS songs
FROM creator cr JOIN (
	SELECT s.creatorID, c.title, COUNT(l.accountID) AS stream
	FROM creates s JOIN content c ON s.contentID = c.contentID
	LEFT JOIN listener l ON l.streams = c.contentID 
    WHERE c.contentID IN (SELECT songID FROM genres) 
    GROUP BY s.creatorID, c.contentID, c.title) 
AS songs ON cr.accountID = songs.creatorID
WHERE cr.stage_name IS NOT NULL GROUP BY cr.accountID, cr.stage_name ORDER BY SUM(songs.stream) ASC, creator_stage_name ASC;

-- -----------------------------------------------------------------------------
-- [2] friends_view()
-- -----------------------------------------------------------------------------
/* This view displays profile information on the friends a user has.
For each user, it displays their account id, full name, and number of distinct friends.
If the user is not a listener, the view shows that the user has 0 friends.
HINT: Can be useful here: UNION and the COALESCE function */
-- -----------------------------------------------------------------------------
create or replace view friends_view as
SELECT u.accountID, u.name, COALESCE(COUNT(DISTINCT combo_friend.friend), 0) AS 'friend_count' FROM user u 
JOIN listener l ON u.accountID=l.accountID
LEFT JOIN (SELECT friender AS u_id, friendee AS friend FROM friends
	UNION
    SELECT friendee AS u_id, friender AS friend FROM friends) AS combo_friend
ON u.accountID = combo_friend.u_id GROUP BY u.accountID, u.name
UNION
SELECT accountID, name, 0 AS 'friend_count' FROM user
WHERE accountID NOT IN (SELECT accountID FROM listener) ORDER BY accountID;


	
-- -----------------------------------------------------------------------------
-- [3] playlists_view()
-- -----------------------------------------------------------------------------
/* This view displays summary information about every playlist on the platform. 
For each playlist it displays the playlist ID and the most frequently appearing album on that playlist.
In the case of a tie between albums, order them alphabetically;
the first album from ascending alphabetical order is chosen.
If the playlist only contains songs that do not belong to any album, the playlist
should not appear in this view.
HINT: Subqueries, min(), and max() can be helpful here.
*/
-- -----------------------------------------------------------------------------
create or replace view playlists_view as
SELECT playlistID, MIN(album_name) AS 'top_album' FROM (
	SELECT m.playlistID, s.album_name FROM makes_up m
    JOIN song s ON m.songID = s.contentID WHERE s.album_name IS NOT NULL
    GROUP BY m.playlistID, s.album_name HAVING COUNT(*) = (
		SELECT MAX(frequency) FROM (
			SELECT COUNT(*) AS frequency FROM makes_up ma
            JOIN song ss ON ma.songID = ss.contentID
            WHERE ma.playlistID = m.playlistID GROUP BY ss.album_name)
		AS album_count
	))
AS top_albums GROUP BY playlistID ORDER BY playlistID;


    
-- [4] two_creator_view
-- -------------------------------------------------------------------------
/* This view gives information about just two creators.
Retrieve a list of the creators' socials in a comma-separated list of the format 
"Platform: Handle", the song pinned on their creator profile if one exists 
(null if one doesn't), and a comma-separated list of the genres this creator 
has made songs in. This view should only look at the 3rd and 4th rows 
of the creator table.
HINT: GROUP_CONCAT() and the separator clause can be helpful here.
*/
-- ---------------------------------------------------------------------------
create or replace view two_creator_view as
SELECT
GROUP_CONCAT(DISTINCT CONCAT(s.platform, ': ', s.handle) ORDER BY s.platform SEPARATOR ', ') AS handles,
c.contentID AS pinned,
GROUP_CONCAT(DISTINCT g.genre ORDER BY g.genre SEPARATOR ', ') AS genres
FROM (SELECT * FROM creator LIMIT 2 OFFSET 2) cr
LEFT JOIN socials s ON cr.accountID = s.creatorID
LEFT JOIN content c ON cr.pinned = c.contentID
LEFT JOIN creates ct ON cr.accountID = ct.creatorID
LEFT JOIN genres g ON ct.contentID = g.songID
GROUP BY cr.accountID, c.title;



-- [5] podcasts_view
-- -------------------------------------------------------------------------
/* This view provides an overview of all podcasts, including the podcast ID, title,
number of episodes, and total length in hours of all episodes combined.
Report the length to 4 decimal places. */
-- ---------------------------------------------------------------------------
create or replace view podcasts_view as
select ps.podcastID, ps.title, count(pe.episode_number) as num_episodes, round(sum(c.content_length)/3600,4) as total_length FROM
podcast_episode pe join podcast_series ps ON pe.podcastID = ps.podcastID
join content c ON c.contentID = pe.contentID group by ps.podcastID;


-- [6] subscriptions_view
-- ---------------------------------------------------------------------------
/* This view lists all subscriptions by the following details:
the subscription ID, the user enrolled in this subscription,
the type of plan (Family or Individual), maximum number of users (for Family plans), 
tier (for Individual plans), start date, end date, the status of the subscription (Inactive or Active),
and if the plan is Active, how many days remaining until expiration from the current date. 
If the plan is Inactive, display null remaining days. Order this view by subscription ID ascending.
HINT: The CURDATE and TIMESTAMPDIFF functions can be helpful here.*/
-- ---------------------------------------------------------------------------
create or replace view subscriptions_view as
SELECT s.subscriptionID, l.accountID AS enrolled_user, s.subscription_type, s.max_family_size,
s.tier, s.start_date, s.end_date,
IF(s.end_date >= CURDATE(), 'Active', 'Inactive') AS status,
IF(s.end_date >= CURDATE(), TIMESTAMPDIFF(DAY, CURDATE(), s.end_date), NULL) AS days_remaining
FROM subscription s LEFT JOIN listener l ON s.subscriptionID = l.subscription ORDER BY s.subscriptionID ASC;



-- [7] genre_distribution_view
-- ---------------------------------------------------------------------------
/* This view shows the distribution of songs across different genres. 
It displays each genre with the number of songs that belong to that genre
and lists the content IDs of those songs ordered alphabetically 
and separated by a semi-colon and a space. 
Order the genres of this view in descending order of how many songs belong to a genre. 
HINT: GROUP_CONCAT() and the separator clause can be helpful here. */
-- ---------------------------------------------------------------------------
create or replace view genre_distribution_view as
select g.genre, count(*) as "num songs", group_concat(g.songID ORDER BY s.contentID SEPARATOR '; ') as 'content IDs' 
from genres g join song s on s.contentID = g.songID group by g.genre order by "num songs" desc;


-- [8] recent_subscriptions_view
-- ---------------------------------------------------------------------------
/* This view lists the details of the 3 most recent subscription enrollments.
Select each listener's full name, the subscription ID they are enrolled in, 
and the cost of the plan. Order this view from newest to oldest enrollment date,
breaking ties by the listeners' names in ascending alphabetical order. */
-- ---------------------------------------------------------------------------
create or replace view recent_subscriptions_view as
select u.name, s.subscriptionID, s.cost from user u join listener l on 
u.accountID = l.accountID join subscription s on s.subscriptionID = l.subscription order by s.start_date desc,u.name asc limit 3;


-- [9] count_streams_view
-- ---------------------------------------------------------------------------
/* This view shows the number of users streaming the song that holds the highest
track order in every playlist. For every playlist that contains at least 1 song,
select the song ID of the last song based on the track order. 
Then, for each of these songs, select how many users are currently streaming the song, 
even if there are 0 users streaming. 
HINT: COALESCE() can be helpful here. */
-- ---------------------------------------------------------------------------
create or replace view count_streams_view as
SELECT last_songs.songID, COALESCE(COUNT(l.accountID), 0) AS num_streaming
FROM
(SELECT m.songID FROM makes_up m JOIN ( SELECT playlistID, MAX(track_order) AS max_track FROM makes_up
	GROUP BY playlistID) AS max_tracks
	ON m.playlistID = max_tracks.playlistID
	AND m.track_order = max_tracks.max_track
) AS last_songs
LEFT JOIN listener l ON l.streams = last_songs.songID GROUP BY last_songs.songID;





