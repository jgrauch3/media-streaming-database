# Media Streaming Service: Database Architecture & Backend Logic

## Overview
This project involves the end-to-end design and implementation of a relational database for a media streaming platform (similar to Spotify/Netflix). [cite_start]The system manages complex interactions between **Users, Creators, Listeners, and Content**[cite: 66, 72, 82].

## Technical Highlights
* [cite_start]**Complex Schema:** Architected a relational schema with **20+ tables** including Songs, Podcast Episodes, Albums, and Playlists[cite: 33, 96, 117, 125].
* [cite_start]**Data Integrity:** Applied **3rd Normal Form (3NF)** and ER cardinalities ($1:1$, $1:N$, $M:N$) to ensure zero redundancy[cite: 34, 51, 154].
* [cite_start]**Automation:** Engineered **SQL Stored Procedures** to automate backend logic, including subscription renewal, content streaming, and social media management[cite: 36, 153].

## System Architecture
![ER Diagram](images/ER_Diagram.png)

## Key Mechanisms Implemented
* [cite_start]**Subscription Management:** Automated end-date extensions and family plan validation[cite: 36, 69].
* [cite_start]**Content Streaming:** Implemented age-based maturity checks (e.g., users must be 18+ for 'Explicit' content)[cite: 36, 37].
* [cite_start]**Playlist Logic:** Designed complex procedures for duplicating, merging, and resequencing playlist track orders[cite: 36, 138, 144].
