DROP TABLE IF EXISTS users;

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL
);

-- Create a default user, The password is 'password' (MD5 hashed)
INSERT INTO users (username, email, password) 
    VALUES ('admin', 'keamonk1@stud.kea.dk', '5f4dcc3b5aa765d61d8327deb882cf99');


CREATE TABLE IF NOT EXISTS pages (
    title TEXT PRIMARY KEY UNIQUE,
    url TEXT NOT NULL UNIQUE,
    language TEXT NOT NULL CHECK(language IN ('en', 'da')) DEFAULT 'en', -- How you define ENUM type in SQLite
    last_updated TIMESTAMP,
    content TEXT NOT NULL
);

INSERT INTO pages (title, url, language, last_updated, content)
VALUES
('To Kill a Mockingbird', 'https://www.goodreads.com/book/show/2657.To_Kill_a_Mockingbird', 'en', 
 '2024-11-01 10:15:00', 'A novel about the injustices of race and class in the Deep South.'),
('Pride and Prejudice', 'https://www.goodreads.com/book/show/1885.Pride_and_Prejudice', 'en', 
 '2024-11-02 12:30:00', 'The classic tale of love and misunderstanding set in rural England.'),
('Crime and Punishment', 'https://www.goodreads.com/book/show/7144.Crime_and_Punishment', 'en', 
 '2024-11-03 14:45:00', 'A psychological exploration of guilt and redemption in 19th-century Russia.'),
('The Little Prince', 'https://www.goodreads.com/book/show/157993.The_Little_Prince', 'da', 
 '2024-11-04 16:00:00', 'En klassisk fortælling om kærlighed, tab og nysgerrighed.'),
('The Hitchhiker’s Guide to the Galaxy', 'https://www.goodreads.com/book/show/11.The_Hitchhiker_s_Guide_to_the_Galaxy', 'en', 
 '2024-11-05 17:30:00', 'A comedic science fiction adventure across space.'),
('Niels Lyhne', 'https://www.goodreads.com/book/show/124552.Niels_Lyhne', 'da', 
 '2024-11-06 19:15:00', 'En eksistentiel roman om menneskets tro og tvivl.'),
('The Great Gatsby', 'https://www.goodreads.com/book/show/4671.The_Great_Gatsby', 'en', 
 '2024-11-07 20:45:00', 'A tragic story of wealth, ambition, and unrequited love in 1920s America.'),
('1984', 'https://www.goodreads.com/book/show/5470.1984', 'en', 
 '2024-11-08 22:00:00', 'A dystopian novel that explores the dangers of totalitarianism and extreme surveillance.'),
('The Catcher in the Rye', 'https://www.goodreads.com/book/show/5107.The_Catcher_in_the_Rye', 'en', 
 '2024-12-01 09:00:00', 'A story about teenage rebellion and the search for identity.'),
('Brave New World', 'https://www.goodreads.com/book/show/5129.Brave_New_World', 'en', 
 '2024-12-02 10:15:00', 'A dystopian novel depicting a technologically advanced but emotionally shallow society.'),
('Moby-Dick', 'https://www.goodreads.com/book/show/153747.Moby_Dick_or_the_Whale', 'en', 
 '2024-12-03 11:30:00', 'A tale of obsession and revenge set against the backdrop of whaling adventures.'),
('The Alchemist', 'https://www.goodreads.com/book/show/865.The_Alchemist', 'en', 
 '2024-12-04 12:45:00', 'A philosophical novel about following your dreams and seeking your personal legend.'),
('Anne of Green Gables', 'https://www.goodreads.com/book/show/8127.Anne_of_Green_Gables', 'en', 
 '2024-12-05 14:00:00', 'A heartwarming story about an imaginative orphan finding her place in the world.'),
('Hamlet', 'https://www.goodreads.com/book/show/1420.Hamlet', 'en', 
 '2024-12-06 15:15:00', 'Shakespeare’s iconic tragedy of betrayal, revenge, and madness.'),
('The Road', 'https://www.goodreads.com/book/show/6288.The_Road', 'en', 
 '2024-12-07 16:30:00', 'A post-apocalyptic journey of a father and son struggling to survive.'),
('War and Peace', 'https://www.goodreads.com/book/show/656.War_and_Peace', 'en', 
 '2024-12-08 17:45:00', 'An epic novel exploring love, family, and politics during the Napoleonic Wars.'),
('The Book Thief', 'https://www.goodreads.com/book/show/19063.The_Book_Thief', 'en', 
 '2024-12-09 10:00:00', 'A moving story set in Nazi Germany, narrated by Death, about a girl who finds solace in stealing books.'),
('Wuthering Heights', 'https://www.goodreads.com/book/show/6185.Wuthering_Heights', 'en', 
 '2024-12-10 11:15:00', 'A tale of passionate and destructive love set in the Yorkshire moors.'),
('Don Quixote', 'https://www.goodreads.com/book/show/3836.Don_Quixote', 'en', 
 '2024-12-11 12:30:00', 'A comedic and tragic story of a man who believes himself a knight-errant.'),
('Frankenstein', 'https://www.goodreads.com/book/show/18490.Frankenstein', 'en', 
 '2024-12-12 13:45:00', 'A gothic novel about the creation of a monster and its tragic consequences.'),
('Les Misérables', 'https://www.goodreads.com/book/show/24280.Les_Mis_rables', 'en', 
 '2024-12-13 14:00:00', 'An epic story of redemption, justice, and love set in revolutionary France.'),
('The Hobbit', 'https://www.goodreads.com/book/show/5907.The_Hobbit', 'en', 
 '2024-12-10 09:00:00', 'A fantastical adventure of a hobbit’s journey to recover a treasure guarded by a dragon.'),
('The Divine Comedy', 'https://www.goodreads.com/book/show/172418.The_Divine_Comedy', 'en', 
 '2024-12-11 10:30:00', 'A classic Italian poem exploring the realms of Hell, Purgatory, and Heaven.'),
('Jane Eyre', 'https://www.goodreads.com/book/show/10210.Jane_Eyre', 'en', 
 '2024-12-12 12:00:00', 'A story of love and independence, set against the backdrop of Victorian England.'),
('The Odyssey', 'https://www.goodreads.com/book/show/1381.The_Odyssey', 'en', 
 '2024-12-13 13:15:00', 'An epic tale of adventure and heroism during Odysseus’s journey home.'),
('Anna Karenina', 'https://www.goodreads.com/book/show/15823480-anna-karenina', 'en', 
 '2024-12-14 14:00:00', 'A tragic love story set against the backdrop of Russian high society.'),
('Dracula', 'https://www.goodreads.com/book/show/17245.Dracula', 'en', 
 '2024-12-15 15:00:00', 'A Gothic horror novel about the infamous Count Dracula and his reign of terror.'),
('The Brothers Karamazov', 'https://www.goodreads.com/book/show/4934.The_Brothers_Karamazov', 'en', 
 '2024-12-16 16:00:00', 'A philosophical exploration of faith, doubt, and family conflicts in 19th-century Russia.'),
('Great Expectations', 'https://www.goodreads.com/book/show/2623.Great_Expectations', 'en', 
 '2024-12-17 17:00:00', 'A coming-of-age story about ambition, love, and self-discovery in Victorian England.'),
('The Picture of Dorian Gray', 'https://www.goodreads.com/book/show/5297.The_Picture_of_Dorian_Gray', 'en', 
 '2024-12-18 18:00:00', 'A cautionary tale about vanity, morality, and the pursuit of eternal youth.'),
('Sense and Sensibility', 'https://www.goodreads.com/book/show/14935.Sense_and_Sensibility', 'en', 
 '2024-12-19 19:00:00', 'A tale of two sisters navigating love and societal expectations.'),
('Madame Bovary', 'https://www.goodreads.com/book/show/2175.Madame_Bovary', 'en', 
 '2024-12-20 09:30:00', 'A novel about a woman’s pursuit of passion and the consequences of her choices.'),
('Fahrenheit 451', 'https://www.goodreads.com/book/show/17470674-fahrenheit-451', 'en', 
 '2024-12-21 10:30:00', 'A dystopian novel about a society where books are banned and critical thinking is suppressed.'),
('The Count of Monte Cristo', 'https://www.goodreads.com/book/show/7126.The_Count_of_Monte_Cristo', 'en', 
 '2024-12-22 11:45:00', 'A gripping story of betrayal, revenge, and redemption.'),
('The Stranger', 'https://www.goodreads.com/book/show/49552.The_Stranger', 'en', 
 '2024-12-23 12:00:00', 'An existential novel about a man’s indifferent attitude toward life and society.'),
('The Wind-Up Bird Chronicle', 'https://www.goodreads.com/book/show/11275.The_Wind_Up_Bird_Chronicle', 'en', 
 '2024-12-24 13:00:00', 'A surreal exploration of loss, war, and the mysteries of life in modern Japan.'),
('A Tale of Two Cities', 'https://www.goodreads.com/book/show/1953.A_Tale_of_Two_Cities', 'en', 
 '2024-12-10 10:00:00', 'A historical novel set during the French Revolution, exploring themes of love and sacrifice.'),
('Beloved', 'https://www.goodreads.com/book/show/6149.Beloved', 'en', 
 '2024-12-11 11:30:00', 'A haunting tale of slavery, memory, and motherhood in post-Civil War America.'),
('Catch-22', 'https://www.goodreads.com/book/show/168668.Catch_22', 'en', 
 '2024-12-12 12:15:00', 'A satirical novel about the absurdities of war and bureaucracy during WWII.'),
('One Hundred Years of Solitude', 'https://www.goodreads.com/book/show/320.One_Hundred_Years_of_Solitude', 'en', 
 '2024-12-13 13:45:00', 'A magical realism masterpiece chronicling the rise and fall of the Buendía family in Colombia.')
;
